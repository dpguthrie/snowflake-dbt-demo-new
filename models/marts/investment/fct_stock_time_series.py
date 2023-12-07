import pandas as pd
import snowflake.snowpark.functions as F


CALC_HELPER = {
    'sma': [50, 200],
    'ema': [12, 20, 26],
}


def model(dbt, session):
    dbt.config(
        materialized="incremental",
        packages=["pandas"]
    )

    df = dbt.ref('stg_stocks__history')

    if dbt.is_incremental():
        df = df.filter(df.date >= F.dateadd("day", F.lit(-202), F.current_date()))

    df = df.to_pandas()
    df.sort_values(by=['symbol', 'date'], inplace=True)

    # Add in Moving Averages
    for n in CALC_HELPER['sma']:
        df[f'sma_{n}'] = df.groupby('symbol')['close'].rolling(window=n).mean()

    # Add in Exponential Moving Averages (12, 20, 26)
    for n in CALC_HELPER['ema']:
        df[f'ema_{n}'] = df.groupby('symbol')['close'].ewm(span=n, adjust=False).mean()

    return df