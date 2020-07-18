from abc import ABC, abstractmethod
import altair as alt
import datetime
import logging
import numpy as np
import pandas as pd
from pathlib import Path
import sqlalchemy
from sqlalchemy.sql import select, text

from . import util


class AbstractChart(ABC):
    def __init__(self, engine, output_dir,
                 output_formats=frozenset(['json'])):
        self.engine = engine
        self.metadata = sqlalchemy.MetaData(engine)
        self.output_dir = output_dir
        self.output_formats = output_formats
        self.name = type(self).__name__

    def render(self, bulletin_dates):
        with self.engine.connect() as connection:
            df = self.fetch_data(connection)
        logging.info("%s dataframe: %s", self.name, util.describe_frame(df))

        for bulletin_date in bulletin_dates:
            self.render_bulletin_date(df, bulletin_date)

    def render_bulletin_date(self, df, bulletin_date):
        bulletin_dir = Path(f'{self.output_dir}/{bulletin_date}')
        bulletin_dir.mkdir(exist_ok=True)
        util.save_chart(self.make_chart(self.filter_data(df, bulletin_date)),
                        f"{bulletin_dir}/{bulletin_date}_{self.name}",
                        self.output_formats)

    @abstractmethod
    def make_chart(self, df):
        pass

    @abstractmethod
    def fetch_data(self, connection):
        pass

    def filter_data(self, df, bulletin_date):
        """Filter dataframe according to given bulletin_date.  May want to override."""
        return df.loc[df['bulletin_date'] == pd.to_datetime(bulletin_date)]


class AbstractMismatchChart(AbstractChart):
    def filter_data(self, df, bulletin_date):
        until = pd.to_datetime(bulletin_date)
        return df.loc[df['bulletin_date'] <= until]

    def make_chart(self, df):
        base = alt.Chart(df).encode(
            x=alt.X('date(bulletin_date):O',
                    title="Día del mes", sort="descending",
                    axis=alt.Axis(format='%d')),
            y=alt.Y('month(bulletin_date):O',
                    title=None, sort="descending",
                    axis=alt.Axis(format='%B')),
            tooltip=['bulletin_date:T', 'value']
        )

        heatmap = base.mark_rect().encode(
            color=alt.Color('value:Q', title=None, legend=None,
                            scale=alt.Scale(scheme="redgrey", domainMid=0,
                                            # WORKAROUND: Set the domain manually to forcibly
                                            # include zero or else we run into
                                            # https://github.com/vega/vega-lite/issues/6544
                                            domain=alt.DomainUnionWith(unionWith=[0])))
        )

        text = base.mark_text(fontSize=9).encode(
            text=alt.Text('value:Q'),
            color=util.heatmap_text_color(df, 'value')
        )

        return (heatmap + text).properties(
            width=585, height=70
        ).facet(
            row=alt.Row('variable', title=None,
                        sort=['Confirmados',
                              'Probables',
                              'Muertes'])
        )


class ConsecutiveBulletinMismatch(AbstractMismatchChart):
    def fetch_data(self, connection):
        table = sqlalchemy.Table('mismatched_announcement_aggregates', self.metadata,
                                 schema='quality', autoload=True)
        query = select([table.c.bulletin_date,
                        (table.c.cumulative_confirmed_cases
                           - table.c.computed_cumulative_confirmed_cases)\
                           .label('confirmed_cases_mismatch'),
                        (table.c.cumulative_probable_cases
                           - table.c.computed_cumulative_probable_cases)\
                           .label('probable_cases_mismatch'),
                        (table.c.cumulative_deaths
                           - table.c.computed_cumulative_deaths)\
                           .label('deaths_mismatch'),
                        ])
        df = pd.read_sql_query(query, connection, parse_dates=['bulletin_date'])
        df = df.rename(columns={
            'confirmed_cases_mismatch': 'Confirmados',
            'probable_cases_mismatch': 'Probables',
            'deaths_mismatch': 'Muertes'
        })
        return pd.melt(df, ['bulletin_date']).dropna()



class BulletinChartMismatch(AbstractMismatchChart):
    def fetch_data(self, connection):
        table = sqlalchemy.Table('mismatched_announcement_and_chart', self.metadata,
                                 schema='quality', autoload=True)
        query = select([table.c.bulletin_date,
                        (table.c.cumulative_confirmed_cases - table.c.sum_confirmed_cases)\
                           .label('confirmed_cases_mismatch'),
                        (table.c.cumulative_probable_cases - table.c.sum_probable_cases)\
                           .label('probable_cases_mismatch'),
                        (table.c.cumulative_deaths - table.c.sum_deaths)\
                           .label('deaths_mismatch'),
                        ])
        df = pd.read_sql_query(query, connection, parse_dates=['bulletin_date'])
        df = df.rename(columns={
            'confirmed_cases_mismatch': 'Confirmados',
            'probable_cases_mismatch': 'Probables',
            'deaths_mismatch': 'Muertes'
        })
        return pd.melt(df, ['bulletin_date']).dropna()


class Cumulative(AbstractChart):
    def make_chart(self, df):
        return alt.Chart(df).mark_line(point=True).encode(
            x=alt.X('yearmonthdate(datum_date):T', title=None,
                    axis=alt.Axis(format='%d/%m')),
            y=alt.Y('value', title=None, scale=alt.Scale(type='log')),
            color=alt.Color('variable', title=None,
                            legend=alt.Legend(orient="top", labelLimit=250, columns=2),
                            sort=['Casos confirmados (fecha muestra)',
                                  'Pruebas positivas (fecha boletín)',
                                  'Casos (fecha boletín)',
                                  'Casos probables (fecha muestra)',
                                  'Muertes (fecha muerte)',
                                  'Muertes (fecha boletín)']),
            tooltip=['datum_date', 'variable', 'value']
        ).properties(
            width=600, height=400
        )

    def fetch_data(self, connection):
        table = sqlalchemy.Table('cumulative_data', self.metadata,
                                 schema='products', autoload=True)
        query = select([table.c.bulletin_date,
                        table.c.datum_date,
                        table.c.confirmed_cases,
                        table.c.probable_cases,
                        table.c.positive_results,
                        table.c.announced_cases,
                        table.c.deaths,
                        table.c.announced_deaths])
        df = pd.read_sql_query(query, connection,
                               parse_dates=["bulletin_date", "datum_date"])
        df = df.rename(columns={
            'confirmed_cases': 'Casos confirmados (fecha muestra)',
            'probable_cases': 'Casos probables (fecha muestra)',
            'positive_results': 'Pruebas positivas (fecha boletín)',
            'announced_cases': 'Casos (fecha boletín)',
            'deaths': 'Muertes (fecha muerte)',
            'announced_deaths': 'Muertes (fecha boletín)'
        })
        return pd.melt(df, ["bulletin_date", "datum_date"])


class NewCases(AbstractChart):
    def make_chart(self, df):
        max_value = df['value'].max()

        base = alt.Chart(df.dropna()).transform_window(
            frame=[-6, 0],
            mean_value='mean(value)',
            groupby=['variable']
        ).encode(
            x=alt.X('yearmonthdate(datum_date):T', title=None,
                    axis=alt.Axis(format='%d/%m'))
        )

        scatter = base.mark_point(opacity=0.5, clip=True).encode(
            y=alt.Y('value:Q', title=None,
                    scale=alt.Scale(type='symlog', domain=[0, max_value])),
            tooltip=[
                alt.Tooltip('datum_date:T', title='Fecha muestra o muerte'),
                alt.Tooltip('variable:N', title='Variable'),
                alt.Tooltip('value:Q', title='Valor crudo'),
                alt.Tooltip('mean_value:Q', format='.1f', title='Promedio 7 días')]
        )

        average = base.mark_line(strokeWidth=3, point='transparent').encode(
            y=alt.Y('mean_value:Q', title=None,
                    scale=alt.Scale(type='symlog', domain=[0, max_value])),
            tooltip = [
                alt.Tooltip('datum_date:T', title='Fecha muestra o muerte'),
                alt.Tooltip('variable:N', title='Variable'),
                alt.Tooltip('mean_value:Q', format='.1f', title='Promedio 7 días')]
        )

        return (average + scatter).encode(
            color=alt.Color('variable', title=None,
                            legend=alt.Legend(orient="top", labelLimit=250),
                            sort=['Confirmados',
                                  'Probables',
                                  'Muertes'])
        ).properties(
            width=600, height=400
        )

    def fetch_data(self, connection):
        table = sqlalchemy.Table('bitemporal', self.metadata, autoload=True)
        query = select([table.c.bulletin_date,
                        table.c.datum_date,
                        table.c.confirmed_cases,
                        table.c.probable_cases,
                        table.c.deaths])
        df = pd.read_sql_query(query, connection,
                               parse_dates=["bulletin_date", "datum_date"])
        df = df.rename(columns={
            'confirmed_cases': 'Confirmados',
            'probable_cases': 'Probables',
            'deaths': 'Muertes'
        })
        return pd.melt(df, ["bulletin_date", "datum_date"])


class AbstractLateness(AbstractChart):
    def fetch_data_for_table(self, connection, table):
        query = select([table.c.bulletin_date,
                        table.c.confirmed_cases_additions,
                        table.c.probable_cases_additions,
                        table.c.deaths_additions]
        )
        df = pd.read_sql_query(query, connection,
                               parse_dates=["bulletin_date"])
        df = df.rename(columns={
            'confirmed_cases_additions': 'Confirmados',
            'probable_cases_additions': 'Probables',
            'deaths_additions': 'Muertes'
        })
        return pd.melt(df, "bulletin_date")

    def filter_data(self, df, bulletin_date):
        since_date = pd.to_datetime(bulletin_date - datetime.timedelta(days=8))
        until_date = pd.to_datetime(bulletin_date)
        return df.loc[(since_date < df['bulletin_date'])
                      & (df['bulletin_date'] <= until_date)]


class LatenessDaily(AbstractLateness):
    def make_chart(self, df):
        sort_order = ['Confirmados',
                      'Probables',
                      'Muertes']
        bars = alt.Chart(df).mark_bar().encode(
            x=alt.X('value', title="Rezago estimado (días)"),
            y=alt.Y('variable', title=None, sort=sort_order, axis=None),
            color=alt.Color('variable', sort=sort_order,
                            legend=alt.Legend(orient='bottom', title=None)),
            tooltip=[alt.Tooltip('bulletin_date:T', title='Fecha de boletín'),
                     alt.Tooltip('variable:N', title='Variable'),
                     alt.Tooltip('value:Q', format=".1f", title='Rezago promedio')]
        )

        text = bars.mark_text(
            align='right',
            baseline='middle',
            size=12,
            dx=-5
        ).encode(
            text=alt.Text('value:Q', format='.1f'),
            color = alt.value('white')
        )

        return (bars + text).properties(
            width=300,
        ).facet(
            columns=2,
            facet=alt.Facet("bulletin_date", sort="descending", title="Fecha del boletín")
        )


    def fetch_data(self, connection):
        table = sqlalchemy.Table('lateness_daily', self.metadata,
                                 schema='products', autoload=True)
        return self.fetch_data_for_table(connection, table)


class Lateness7Day(AbstractLateness):
    def make_chart(self, df):
        sort_order = ['Confirmados',
                      'Probables',
                      'Muertes']
        lines = alt.Chart(df).mark_line(
            strokeWidth=3,
            point=alt.OverlayMarkDef(size=50)
        ).encode(
            x=alt.X('yearmonthdate(bulletin_date):O',
                    title="Fecha boletín",
                    axis=alt.Axis(format='%d/%m', titlePadding=10)),
            y=alt.Y('value:Q', title=None),
            color = alt.Color('variable', sort=sort_order, legend=None),
            tooltip=[alt.Tooltip('bulletin_date:T', title='Fecha de boletín'),
                     alt.Tooltip('variable:N', title='Variable'),
                     alt.Tooltip('value:Q', format=".1f", title='Rezago promedio')]
        )

        text = lines.mark_text(
            align='center',
            baseline='line-top',
            size=15,
            dy=10
        ).encode(
            text=alt.Text('value:Q', format='.1f')
        )

        return (lines + text).properties(
            width=550, height=37
        ).facet(
            row=alt.Row('variable', title=None, sort=sort_order)
        )

    def fetch_data(self, connection):
        table = sqlalchemy.Table('lateness_7day', self.metadata,
                                 schema='products', autoload=True)
        return self.fetch_data_for_table(connection, table)


class CurrentDeltas(AbstractChart):
    def make_chart(self, df):
        base = alt.Chart(df).encode(
            x=alt.X('date(datum_date):O',
                    title="Día del mes", sort="descending",
                    axis=alt.Axis(format='%d')),
            y=alt.Y('month(datum_date):O',
                    title=None, sort="descending",
                    axis=alt.Axis(format='%B')),
            tooltip=[alt.Tooltip('datum_date:T', title='Fecha de muestra o muerte'),
                     alt.Tooltip('value:Q', title='Casos añadidos (o restados)')]
        )

        heatmap = base.mark_rect().encode(
            color=alt.Color('value:Q', title=None, legend=None,
                            scale=alt.Scale(scheme="redgrey", domainMid=0,
                                            # WORKAROUND: Set the domain manually to forcibly
                                            # include zero or else we run into
                                            # https://github.com/vega/vega-lite/issues/6544
                                            domain=alt.DomainUnionWith(unionWith=[0])))
        )

        text = base.mark_text(fontSize=9).encode(
            text=alt.Text('value:Q'),
            color=util.heatmap_text_color(df, 'value')
        ).transform_filter("(datum.value !== 0) & (datum.value !== null)")

        return (heatmap + text).properties(
            width=585, height=70
        ).facet(
            row=alt.Row('variable', title=None,
                        sort=['Confirmados',
                              'Probables',
                              'Muertes'])
        )

    def fetch_data(self, connection):
        table = sqlalchemy.Table('daily_deltas', self.metadata,
                                 schema='products', autoload=True)
        query = select([table.c.bulletin_date,
                        table.c.datum_date,
                        table.c.delta_confirmed_cases,
                        table.c.delta_probable_cases,
                        table.c.delta_deaths]
        )
        df = pd.read_sql_query(query, connection,
                               parse_dates=["bulletin_date", "datum_date"])
        df = df.rename(columns={
            'delta_confirmed_cases': 'Confirmados',
            'delta_probable_cases': 'Probables',
            'delta_deaths': 'Muertes'
        })
        return pd.melt(df, ["bulletin_date", "datum_date"]) \
            .replace(0, np.nan)


class DailyDeltas(AbstractChart):
    def make_chart(self, df):
        base = alt.Chart(df).mark_rect().encode(
            x=alt.X('yearmonthdate(datum_date):O',
                    title="Fecha evento", sort="descending",
                    axis=alt.Axis(format='%d/%m')),
            y=alt.Y('yearmonthdate(bulletin_date):O',
                    title=None, sort="descending",
                    axis=alt.Axis(format='%d/%m')),
            tooltip=[alt.Tooltip('bulletin_date:T', title='Fecha de boletín'),
                     alt.Tooltip('datum_date:T', title='Fecha de muestra o muerte'),
                     alt.Tooltip('value:Q', title='Casos añadidos (o restados)')]
        )

        heatmap = base.mark_rect().encode(
            color=alt.Color('value:Q', title=None, legend=None,
                            scale=alt.Scale(scheme="redgrey", domainMid=0,
                                            # WORKAROUND: Set the domain manually to forcibly
                                            # include zero or else we run into
                                            # https://github.com/vega/vega-lite/issues/6544
                                            domain=alt.DomainUnionWith(unionWith=[0])))
        )

        text = base.mark_text(fontSize=4).encode(
            text=alt.Text('value:Q'),
            color=util.heatmap_text_color(df, 'value')
        )

        return (heatmap + text).properties(
            width=585, height=120
        ).facet(
            row=alt.Row('variable', title=None,
                        sort=['Confirmados',
                              'Probables',
                              'Muertes'])
        )

    def fetch_data(self, connection):
        table = sqlalchemy.Table('daily_deltas', self.metadata,
                                 schema='products', autoload=True)
        query = select([table.c.bulletin_date,
                        table.c.datum_date,
                        table.c.delta_confirmed_cases,
                        table.c.delta_probable_cases,
                        table.c.delta_deaths]
        )
        df = pd.read_sql_query(query, connection,
                               parse_dates=["bulletin_date", "datum_date"])
        df = df.rename(columns={
            'delta_confirmed_cases': 'Confirmados',
            'delta_probable_cases': 'Probables',
            'delta_deaths': 'Muertes'
        })
        return pd.melt(df, ["bulletin_date", "datum_date"])

    def filter_data(self, df, bulletin_date):
        since_date = pd.to_datetime(bulletin_date - datetime.timedelta(days=14))
        until_date = pd.to_datetime(bulletin_date)
        filtered = df.loc[(since_date < df['bulletin_date'])
                      & (df['bulletin_date'] <= until_date)]\
            .replace(0, np.nan)\
            .dropna()
        return filtered


class WeekdayBias(AbstractChart):
    def make_chart(self, df):
        confirmed = self.one_variable(df, 'Confirmados', 'Día muestra', 'oranges')
        probable = self.one_variable(df, 'Probables', 'Día muestra', 'reds')
        deaths = self.one_variable(df, 'Muertes', 'Día muerte', 'teals')

        data_date = alt.Chart(df).mark_text(baseline='middle').encode(
            text=alt.Text('bulletin_date',
                          type='temporal',
                          aggregate='max',
                          timeUnit='yearmonthdate',
                          format='Datos hasta: %A %d de %B, %Y'),
        ).properties(
            width=350, height=40
        )

        row1 = alt.hconcat(confirmed, probable, spacing=20).resolve_scale(
            color='independent'
        )

        return alt.vconcat(row1, data_date, deaths, center=True).resolve_scale(
            color='independent'
        )

    def one_variable(self, df, variable,
                     axis_title,
                     color_scheme):
        base = alt.Chart(df).transform_filter(
            alt.datum.variable == variable
        ).transform_filter(
            alt.datum.value > 0
        ).encode(
            color=alt.Color('sum(value):Q', title=None,
                            scale=alt.Scale(type='log', base=2, scheme=color_scheme))
        )

        heatmap = base.mark_rect().encode(
            x=alt.X('day(datum_date):O', title=axis_title),
            y=alt.Y('day(bulletin_date):O', title='Día boletín'),
            tooltip=[alt.Tooltip('variable:N', title='Variable'),
                     alt.Tooltip('day(bulletin_date):O', title='Día de boletín'),
                     alt.Tooltip('day(datum_date):O', title='Día de muestra o muerte'),
                     alt.Tooltip('value:Q', aggregate='sum', title='Casos')]
        )

        right = base.mark_bar().encode(
            x=alt.X('sum(value):Q', title=None, axis=None),
            y=alt.Y('day(bulletin_date):O', title=None, axis=None),
            tooltip=[alt.Tooltip('variable:N', title='Variable'),
                     alt.Tooltip('day(bulletin_date):O', title='Día de boletín'),
                     alt.Tooltip('value:Q', aggregate='sum', title='Casos')]
        )

        top = base.mark_bar().encode(
            x=alt.X('day(datum_date):O', title=None, axis=None),
            y=alt.Y('sum(value):Q', title=None, axis=None),
            tooltip=[alt.Tooltip('variable:N', title='Variable'),
                     alt.Tooltip('day(datum_date):O', title='Día de muestra o muerte'),
                     alt.Tooltip('value:Q', aggregate='sum', title='Casos')]
        )

        heatmap_size = 160
        histogram_size = 40
        return alt.vconcat(
            top.properties(
                width=heatmap_size, height=histogram_size,
                # This title should logically belong to the whole chart,
                # but assigning it to the concat chart anchors it wrong.
                # See: https://altair-viz.github.io/user_guide/generated/core/altair.TitleParams.html
                title=alt.TitleParams(
                    text=variable,
                    anchor='middle',
                    align='center',
                    fontSize=14,
                    fontWeight='normal'
                )
            ),
            alt.hconcat(
                heatmap.properties(
                    width=heatmap_size, height=heatmap_size
                ),
                right.properties(
                    width=histogram_size, height=heatmap_size
                ),
                spacing=3),
            spacing=3
        )

    def fetch_data(self, connection):
        query = text("""SELECT 
	ba.bulletin_date,
	ba.datum_date,
	ba.delta_confirmed_cases,
	ba.delta_probable_cases,
	ba.delta_deaths
FROM bitemporal_agg ba 
WHERE ba.datum_date >= ba.bulletin_date - INTERVAL '14' DAY
AND ba.bulletin_date > (
	SELECT min(bulletin_date)
	FROM bitemporal_agg
	WHERE delta_confirmed_cases IS NOT NULL
	AND delta_probable_cases IS NOT NULL
	AND delta_deaths IS NOT NULL)
ORDER BY bulletin_date, datum_date""")
        df = pd.read_sql_query(query, connection, parse_dates=['bulletin_date', 'datum_date'])
        df = df.rename(columns={
            'delta_confirmed_cases': 'Confirmados',
            'delta_probable_cases': 'Probables',
            'delta_deaths': 'Muertes'
        })
        return pd.melt(df, ['bulletin_date', 'datum_date']).dropna()

    def filter_data(self, df, bulletin_date):
        # We exclude the current bulletin_date because this chart's
        # main use is to compare the current bulletin's data to trends
        # established **before** it.
        cutoff_date = bulletin_date - datetime.timedelta(days=1)
        since_date = pd.to_datetime(cutoff_date - datetime.timedelta(days=21))
        until_date = pd.to_datetime(cutoff_date)
        return df.loc[(since_date < df['bulletin_date'])
                          & (df['bulletin_date'] <= until_date)]


class Municipal(AbstractChart):
    REDS = ('#fad1bd', '#ea9178', '#c74643')
    GRAYS = ('#dadada', '#ababab', '#717171')
    DOMAIN=[0, 6]

    def make_chart(self, df):
        base = alt.Chart(df).transform_impute(
            impute='new_confirmed_cases',
            groupby=['Municipio'],
            key='bulletin_date',
            value=0
        ).mark_area(interpolate='monotone', clip=True).encode(
            x=alt.X('bulletin_date:T', title='Fecha de boletín',
                    axis=alt.Axis(format='%d/%m')),
            y=alt.Y('new_confirmed_cases:Q', title=None, axis=None,
                    scale=alt.Scale(domain=self.DOMAIN)),
            color=alt.value(self.REDS[0]),
            tooltip=[alt.Tooltip('bulletin_date:T', title='Fecha de boletín'),
                     alt.Tooltip('Municipio:N'),
                     alt.Tooltip('new_confirmed_cases:Q', title='Casos confirmados nuevos')]
        )

        def make_band(variable, color, calculate):
            return base.transform_calculate(
                as_=variable, calculate=calculate
            ).encode(
                y=alt.Y(f'{variable}:Q'),
                color=alt.value(color)
            )

        one_above = make_band('one_above', self.REDS[1],
                              alt.datum.new_confirmed_cases - self.DOMAIN[1])
        two_above = make_band('two_above', self.REDS[2],
                              alt.datum.new_confirmed_cases - 2 * self.DOMAIN[1])
        negative = make_band('negative', self.GRAYS[0], -alt.datum.new_confirmed_cases)
        one_below = make_band('one_below', self.GRAYS[1],
                              -alt.datum.new_confirmed_cases - self.DOMAIN[1])
        two_below = make_band('two_below', self.GRAYS[2],
                              -alt.datum.new_confirmed_cases - 2 * self.DOMAIN[1])

        return (base + one_above + two_above
                + negative + one_below + two_below).properties(
            width=525, height=24
        ).facet(
            row=alt.Row('Municipio:N', title=None,
                        header=alt.Header(
                            labelAngle=0,
                            labelFontSize=10,
                            labelAlign='left',
                            labelBaseline='top')),
        ).configure_facet(
            spacing=0
        )

    def fetch_data(self, connection):
        table = sqlalchemy.Table('municipal_agg', self.metadata, autoload=True)
        query = select([table.c.bulletin_date,
                        table.c.municipality,
                        table.c.new_confirmed_cases])\
            .where(table.c.municipality.notin_(['Total']))
        df = pd.read_sql_query(query, connection,
                               parse_dates=["bulletin_date"])
        return df.rename(columns={
            'municipality': 'Municipio'
        })

    def filter_data(self, df, bulletin_date):
        since = pd.to_datetime(bulletin_date - datetime.timedelta(days=35))
        until = pd.to_datetime(bulletin_date)
        return df.loc[(since <= df['bulletin_date']) & (df['bulletin_date'] <= until)]


class MunicipalMap(AbstractChart):
    def make_chart(self, df):
        left_half = self.make_half_chart(
            df, 'd', 'Casos',
            ['Casos nuevos (último boletín)',
             'Casos nuevos (últimos 7)']
        )

        right_half = self.make_half_chart(
            df, '.0%', 'Crecida',
            ['Crecida (último vs 7 anteriores)',
             'Crecida (últimos 7 vs 7 anteriores)']
        )

        return alt.vconcat(left_half, right_half).configure_view(
            strokeWidth=0
        ).configure_concat(
            spacing=40
        )

    def make_half_chart(self, df, number_format, short_title, variables):
        municipalities = self.geography()

        return alt.Chart(municipalities).transform_lookup(
            lookup='properties.NAME',
            from_=alt.LookupData(df, 'Municipio', variables),
            default='0'
        ).mark_geoshape().encode(
            color=alt.Color(alt.repeat('column'), type='quantitative', sort="descending",
                            scale=alt.Scale(type='symlog', scheme='redgrey', domainMid=0,
                                            # WORKAROUND: Set the domain manually to forcibly
                                            # include zero or else we run into
                                            # https://github.com/vega/vega-lite/issues/6544
                                            domain=alt.DomainUnionWith(unionWith=[0])),
                            legend=alt.Legend(orient='bottom', titleLimit=400,
                                              titleOrient='bottom', format=number_format)),
            tooltip=[alt.Tooltip(field='properties.NAME', type='nominal', title='Municipio'),
                     alt.Tooltip(alt.repeat('column'),
                                 type='quantitative',
                                 format=number_format,
                                 title=short_title)]
        ).properties(
            width=300,
            height=125
        ).repeat(
            column=variables
        ).resolve_scale(
            color='independent'
        )


    def geography(self):
        return alt.InlineData(values=util.get_geojson_resource('municipalities.topojson'),
                              format=alt.TopoDataFormat(type='topojson', feature='municipalities'))

    def fetch_data(self, connection):
        table = sqlalchemy.Table('municipal_map', self.metadata,
                                 schema='products', autoload=True)
        query = select([
            table.c.bulletin_date,
            table.c.municipality,
            table.c.new_confirmed_cases,
            table.c.new_7day_confirmed_cases,
            table.c.pct_increase_1day,
            table.c.pct_increase_7day
        ]).where(table.c.municipality.notin_(['Total', 'No disponible', 'Otro lugar fuera de PR']))
        df = pd.read_sql_query(query, connection, parse_dates=["bulletin_date"])
        return df.rename(columns={
            'municipality': 'Municipio',
            'new_confirmed_cases': 'Casos nuevos (último boletín)',
            'new_7day_confirmed_cases': 'Casos nuevos (últimos 7)',
            'pct_increase_1day': 'Crecida (último vs 7 anteriores)',
            'pct_increase_7day': 'Crecida (últimos 7 vs 7 anteriores)'
        })

    def filter_data(self, df, bulletin_date):
        return df.loc[df['bulletin_date'] == pd.to_datetime(bulletin_date)]

class Hospitalizations(AbstractChart):
    def fetch_data(self, connection):
        table = sqlalchemy.Table('hospitalizations', self.metadata, autoload=True)
        query = select([
            table.c.datum_date,
            table.c['Arecibo'],
            table.c['Bayamón'],
            table.c['Caguas'],
            table.c['Fajardo'],
            table.c['Mayagüez'],
            table.c['Metro'],
            table.c['Ponce'],
            table.c['Total']
        ])
        df = pd.read_sql_query(query, connection, parse_dates=['datum_date'])
        return pd.melt(df, ['datum_date'])

    def filter_data(self, df, bulletin_date):
        return df.loc[df['datum_date'] <= pd.to_datetime(bulletin_date + datetime.timedelta(days=1))]

    def make_chart(self, df):
        base = alt.Chart(df).encode(
            x=alt.X('datum_date:T', title='Fecha'),
            y=alt.Y('value:Q', title='Hospitalizados')
        )

        total = base.transform_filter(
            alt.datum['variable'] == 'Total'
        ).mark_area(color='lightgrey', fillOpacity=0.85).encode(
            tooltip=[
                alt.Tooltip('datum_date:T', title='Fecha'),
                alt.Tooltip('value:Q', title='Hospitalizados (total)'),
            ]
        )

        regions = base.transform_filter(
            alt.datum['variable'] != 'Total'
        ).transform_joinaggregate(
            groupby=['datum_date'],
            total='sum(value)'
        ).mark_area(
            fillOpacity=0.85
        ).encode(
            color=alt.Color('variable:N', title='Región',
                            legend=alt.Legend(orient='top')),
            tooltip=[
                alt.Tooltip('datum_date:T', title='Fecha'),
                alt.Tooltip('variable:N', title='Región'),
                alt.Tooltip('value:Q', title='Hospitalizados (región)'),
                alt.Tooltip('total:Q', title='Hospitalizados (total)'),
            ]
        )

        return (total + regions).properties(
            width=575, height=300
        )

class AgeGroups(AbstractChart):
    ORDER = ['< 10', '10-19', '20-29', '30-39', '40-49',
             '50-59', '60-69', '70-79', '≥ 80','No disponible']

    def fetch_data(self, connection):
        table = sqlalchemy.Table('age_groups_molecular_agg', self.metadata, autoload=True)
        query = select([
            table.c.bulletin_date,
            table.c.age_range,
            table.c.cumulative_cases,
            table.c.smoothed_daily_cases
        ]).where(table.c.age_range != 'Total')
        return pd.read_sql_query(query, connection, parse_dates=['bulletin_date'])

    def filter_data(self, df, bulletin_date):
        return df.loc[df['bulletin_date'] <= pd.to_datetime(bulletin_date)]

    def population_data(self):
        table = sqlalchemy.Table('age_groups_population', self.metadata, autoload=True)
        query = select([
            table.c.age_range,
            table.c.total2019
        ]).where(table.c.age_range != 'Total')
        with self.engine.connect() as connection:
            return pd.read_sql_query(query, connection)

    def make_chart(self, df):
        population = self.population_data()

        return alt.Chart(df.dropna()).encode(
        ).transform_filter(
            # We have to filter this out for the per capita chart.
            alt.datum['age_range'] != 'No disponible'
        ).transform_lookup(
            lookup='age_range',
            from_=alt.LookupData(data=population, key='age_range',
                                 fields=['total2019'])
        ).transform_calculate(
            smoothed_daily_cases_1m=alt.expr.if_(
                alt.expr.isNumber(alt.datum.total2019),
                (alt.datum.smoothed_daily_cases * 1_000_000) / alt.datum.total2019,
                None)
        ).mark_area().encode(
            x=alt.X('bulletin_date:T', title='Fecha de boletín'),
            y=alt.Y('smoothed_daily_cases_1m:Q', title=None),
            color=alt.Color('age_range:N', title='Edad', sort=self.ORDER, legend=None),
            tooltip=[
                alt.Tooltip('bulletin_date:T', title='Fecha de boletín'),
                alt.Tooltip('age_range:N', title='Edad'),
                alt.Tooltip('smoothed_daily_cases:Q', format='.1f',
                            title='Casos (7 días)'),
                alt.Tooltip('smoothed_daily_cases_1m:Q', format='.1f',
                            title='Casos (7 días, por millón)')

            ]
        ).properties(
            width=300, height=75
        ).facet(
            columns=2,
            facet=alt.Facet('age_range:N', sort=self.ORDER,
                            title='Casos nuevos por edad (por millón de habitantes, promedio 7 días)')
        )
