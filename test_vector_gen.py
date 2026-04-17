# #=========================================================
# Test vector generator for 16-bit adder design.
# This script generates random input vectors for testing a 16-bit adder. Each vector consists of:
# - A 16-bit unsigned integer A
# - A 16-bit unsigned integer B
# - A 1-bit carry-in (Cin)
# The generated vectors are written to a text file in the format:
# A B Cin
# where A and B are represented as 4-digit hexadecimal numbers, and Cin is a binary digit (0 or 1). 
# # Made by: Isaac Medina and Asher Milberg | Tufts University Department of Electrical and Computer Engineering
# Class of 2027
# Date Created: 4/16/2026
# =========================================================


from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np


def generate_vectors(num_samples: int, seed: int) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    rng = np.random.default_rng(seed)
    a_values = rng.integers(0, 1 << 16, size=num_samples, dtype=np.uint32)
    b_values = rng.integers(0, 1 << 16, size=num_samples, dtype=np.uint32)
    cin_values = rng.integers(0, 2, size=num_samples, dtype=np.uint8)
    return a_values, b_values, cin_values


def write_vector_file(
    output_path: Path,
    a_values: np.ndarray,
    b_values: np.ndarray,
    cin_values: np.ndarray,
) -> None:
    with output_path.open("w", encoding="ascii") as handle:
        for a_value, b_value, cin_value in zip(a_values, b_values, cin_values):
            handle.write(f"{int(a_value):04X} {int(b_value):04X} {int(cin_value)}\n")


def print_summary(a_values: np.ndarray, b_values: np.ndarray, cin_values: np.ndarray) -> None:
    a_bits = ((a_values[:, None] >> np.arange(16)) & 1).astype(np.float64)
    b_bits = ((b_values[:, None] >> np.arange(16)) & 1).astype(np.float64)

    print("Generated random vector set")
    print(f"Samples: {len(a_values)}")
    print(f"P(Cin = 1): {cin_values.mean():.4f}")
    print(f"Mean P(A_i = 1) across 16 bits: {a_bits.mean():.4f}")
    print(f"Mean P(B_i = 1) across 16 bits: {b_bits.mean():.4f}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate 16-bit adder test vectors.")
    parser.add_argument(
        "--num-samples",
        type=int,
        default=10000,
        help="Number of random input samples to generate.",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=24,
        help="Random seed for reproducible vector generation.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("test_vectors.mem"),
        help="Output file for the generated test vectors.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    a_values, b_values, cin_values = generate_vectors(args.num_samples, args.seed)
    write_vector_file(args.output, a_values, b_values, cin_values)
    print_summary(a_values, b_values, cin_values)
    print(f"Wrote vectors to: {args.output.resolve()}")


if __name__ == "__main__":
    main()
