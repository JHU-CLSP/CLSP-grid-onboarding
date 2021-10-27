"""
Given a GZIPped Twitter file, analyze the number of unique URLs in the tweets.

Part of the Minerva onboarding exercise.

Author:
"""
import argparse


def parse_args():
    parser = argparser.ArgumentParser()
    parser.add_argument("--input-files", nargs="+", help="List of tweet files")
    parser.add_argument("--output-dir", type=str, help="Path to output directory")
    return parser.parse_args()


if __name__ == "__main__":
    # Get commandline args
    args = parse_args()

    # Loop through args.input_files and call your URL-counting method
    # Save the results

