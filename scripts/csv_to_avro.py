#!/usr/bin/env python

# Inspired by: https://avro.apache.org/docs/1.10.2/gettingstartedpython.html

import avro.schema
from avro.datafile import DataFileWriter, DataFileReader
from avro.io import DatumWriter, DatumReader
import argparse
import csv
import dataclasses
import io
import typing as t


@dataclasses.dataclass
class Params:
    schema: io.TextIOWrapper
    source: io.TextIOWrapper
    target: io.TextIOWrapper


def parse_params() -> Params:
    parser = argparse.ArgumentParser(description='Convert CSV into AVRO')
    parser.add_argument('--schema', type=argparse.FileType('rb'))
    parser.add_argument('--source', type=argparse.FileType('r'))
    parser.add_argument('--target', type=argparse.FileType('wb'))
    args = parser.parse_args()
    return Params(**vars(args))


# TODO: support more types
def parse_datum(type_: t.Any, val: str) -> t.Any:
    type_name = str(type_)
    if type_name == '"long"':
        return int(val)
    elif type_name == '"double"':
        return float(val)
    elif val == "":
        return None
    else:
        return val


def app(params: Params) -> None:
    schema = avro.schema.parse(params.schema.read())

    source_csv = csv.reader(params.source)
    header = next(source_csv)

    writer = DataFileWriter(params.target, DatumWriter(), schema, codec='deflate')
    for count, row in enumerate(source_csv):
        try:
            row_typed = [parse_datum(field.type, cell) for field, cell in zip(schema.fields, row)]
            writer.append(dict(zip(header, row_typed)))
        except Exception as e:
            print(f"Skipping bad record at {count}: {e}")
    writer.close()

    # reader = DataFileReader(open(params.target.name, "rb"), DatumReader())
    # for data in reader:
    #     print(data)
    # reader.close()


def main() -> None:
    params = parse_params()
    app(params)


if __name__ == "__main__":
    main()
