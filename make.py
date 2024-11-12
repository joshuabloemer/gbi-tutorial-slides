import tomllib
import subprocess
import argparse
import os
import shutil
import re
from uuid import uuid4

def regex_type(pattern: str | re.Pattern):
    """Argument type for matching a regex pattern."""

    def closure_check_regex(arg_value):
        if not re.match(pattern, arg_value):
            raise argparse.ArgumentTypeError("invalid value")
        return arg_value

    return closure_check_regex


def createTut(tut: str, noclicks: bool = False) -> None:
    intermediate = f"{tut}/intermediate-{uuid4()}"
    if not os.path.isdir(tut):
        print(f"Skipping {tut}: folder does not exist")
        return

    if f"{tut}.toml" not in os.listdir(tut):
        print(f"Skipping {tut}: folder does not contain a TOML file")
        return

    with open(f"{tut}/{tut}.toml", "rb") as f:
        config = tomllib.load(f)
    print(f"Creating {tut}: {config['title']}")

    includedFiles = [f"content/{chapter}.ipe" for chapter in config["content"]]

    # find pre and post files
    if "pre.ipe" in os.listdir(tut):
        includedFiles = [f"{tut}/pre.ipe"] + includedFiles
    else:
        includedFiles = ["template/pre.ipe"] + includedFiles

    if "post.ipe" in os.listdir(tut):
        includedFiles = includedFiles + [f"{tut}/post.ipe"]
    else:
        includedFiles = includedFiles + ["template/post.ipe"]

    # copy xkcd
    shutil.copyfile(f"images/xkcd/{config['xkcd']}.png", f"{tut}/xkcd.png")

    # combine contents
    subprocess.run(
        ["ipescript", "scripts/merge"]
        + includedFiles
        + [intermediate + ".ipe"],
        check=True,
    )
    special_char_map = {ord('ä'):'ae', ord('ü'):'ue', ord('ö'):'oe', ord('ß'):'ss',ord('Ä'):'Ae', ord('Ü'):'ue', ord('Ö'):'Oe'}
    basename = config["title"].translate(special_char_map)

    # edit preamble
    subtitle = config["description"].translate(special_char_map)
    subprocess.run(
        ["ipescript", "scripts/edittut"]
        + [intermediate + ".ipe"]
        + [rf"\renewcommand{{\tutinfo}}{{{subtitle}}}"]
        + [intermediate + ".ipe"],
        check=True,
    )
    subprocess.run(
        ["ipescript", "scripts/repalcepreamble"]
        + [intermediate + ".ipe"]
        + [rf"\setcounter{{tutweek}}{{{tut[3:]}}}"]
        + [intermediate + ".ipe"],
        check=True,
    )

    if noclicks:
        subprocess.run(
            ["ipescript", "scripts/noclicks"]
            + [intermediate + ".ipe"]
            + [intermediate + "-print.ipe"],
            check=True,
        )
        subprocess.run(
            [
                "ipetoipe",
                "-pdf",
                "-export",
                intermediate + "-print.ipe",
                f"{tut}/{basename}-print.pdf",
            ],
            check=True,
        )
    else:
        subprocess.run(
            [
                "ipetoipe",
                "-pdf",
                "-export",
                intermediate + ".ipe",
                f"{tut}/{basename}.pdf",
            ],
            check=True,
        )


parser = argparse.ArgumentParser()
parser.add_argument("--print", action="store_true", help="Create Slides without clicks")

group = parser.add_mutually_exclusive_group()
group.add_argument("--all", action="store_true", help="Create all Tutorial files")
group.add_argument(
    "--files",
    nargs="+",
    type=regex_type(r"tut\d{2}"),
    help="Tutorial files to be created",
)
group.add_argument("--clean", action="store_true", help="Delete all Tutorial files")


args = parser.parse_args()


def cleanFolder(tut: str):
    for file in os.listdir(tut):
        if file.endswith(".pdf") or file == "xkcd.png":
            os.remove(f"{tut}/{file}")
        if file.endswith(".ipe") and file.startswith("intermediate-"):
            os.remove(f"{tut}/{file}")


if args.all:
    for tut in os.listdir():
        if re.match(r"tut\d{2}", tut):
            createTut(tut, args.print)
elif args.clean:
    for tut in os.listdir():
        if re.match(r"tut\d{2}", tut):
            cleanFolder(tut)

elif args.files:
    for tut in args.files:
        createTut(tut, args.print)
