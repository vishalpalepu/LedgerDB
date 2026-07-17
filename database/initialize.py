from pathlib import Path
from typing import Iterable

import psycopg2


ROOT = Path(__file__).resolve().parent

EXECUTION_ORDER = [
    "schema",
    "indexes",
    "functions/expense",
    "functions/budget",
    "functions/analytics",
    "procedures/budget",
    "procedures/expense",
    "procedures/category",
    "procedures/alerts",
    "procedures/import",
    "views",
    "triggers",
]


class InitializationError(Exception):
    """Raised when database initialization fails."""


def _iter_sql_files(directory: Path) -> Iterable[Path]:
    """
    Returns all SQL files in execution order.

    Files are ordered alphabetically. If ordering becomes important,
    prefix filenames with 001_, 002_, etc.
    """

    if not directory.exists():
        return []

    return sorted(directory.glob("*.sql"))


def _execute_file(cursor, sql_file: Path) -> None:

    with sql_file.open("r", encoding="utf-8") as f:
        cursor.execute(f.read())


def initialize_database(connection_string: str) -> None:
    """
    Initializes a LedgerDB database.

    Executes every SQL file in the required order inside a
    single transaction.

    Raises
    ------
    InitializationError
        If any SQL file fails.
    """

    connection = psycopg2.connect(connection_string)

    try:

        connection.autocommit = False

        with connection.cursor() as cursor:

            for folder in EXECUTION_ORDER:

                directory = ROOT / folder

                if not directory.exists():
                    continue

                for sql_file in _iter_sql_files(directory):

                    try:
                        _execute_file(cursor, sql_file)

                    except Exception as exc:
                        raise InitializationError(
                            f"Failed while executing "
                            f"'{sql_file.relative_to(ROOT)}'\n\n{exc}"
                        ) from exc

        connection.commit()

    except Exception:

        connection.rollback()
        raise

    finally:

        connection.close()