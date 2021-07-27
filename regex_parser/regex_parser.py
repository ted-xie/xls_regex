#!/usr/bin/env python3
"""Turn a regex into NFA."""

import argparse
import os
import sys
from enum import Enum, unique, auto


class NFAState:
  def __init__(self, accepts="", initial=False):
    self.accepts = accepts
    self.initial = initial
    self.neighbors = []

  def set_accepts(self, accepts_):
    self.accepts = accepts_

  def add_neighbor(self, neigh):
    self.neighbors.append(neigh)

  def __str__(self):
    return f"{self.accepts}: neighbors={list(map(lambda st: str(st), self.neighbors))}"


@unique
class RegexToken(Enum):
  TOK_BRACKET_SQUARE_OPEN = auto()
  TOK_BRACKET_SQUARE_CLOS = auto()
  TOK_PAREN_OPEN = auto()
  TOK_PAREN_CLOS = auto()
  TOK_QUESTION_MARK = auto()
  TOK_BACKSLASH = auto()
  TOK_CARAT = auto()
  TOK_DOLLAR_SIGN = auto()
  TOK_DOT = auto()
  TOK_STAR = auto()
  TOK_ESCAPED_PAREN_OPEN = auto()
  TOK_ESCAPED_PAREN_CLOS = auto()
  TOK_ESCAPED_QUESTION_MARK = auto()


class RegexParser:
  def __init__(self, regex, verbose=False):
    self.regex = regex
    self.verbose = verbose
    # Clean this up: Don't actually need to use a dedicated enum yet.
    # The values are discarded during the subsequent sort anyway.
    self.TOKEN_MAP = {
        "\\(": RegexToken.TOK_ESCAPED_PAREN_OPEN,
        "\\)": RegexToken.TOK_ESCAPED_PAREN_CLOS,
        "\\?": RegexToken.TOK_ESCAPED_QUESTION_MARK,
        "[": RegexToken.TOK_BRACKET_SQUARE_OPEN,
        "]": RegexToken.TOK_BRACKET_SQUARE_CLOS,
        "(": RegexToken.TOK_PAREN_OPEN,
        ")": RegexToken.TOK_PAREN_CLOS,
        "?": RegexToken.TOK_QUESTION_MARK
    }
    # Sort the token list by longest tokens.
    self.TOKEN_MAP = sorted(self.TOKEN_MAP, key = lambda tok: len(tok[0]),
        reverse=True)
    self.tokens = []
    self.construct_nfa()


  def get_regex(self):
    """Returns the input regular expression."""
    return self.regex


  def get_tokens(self):
    """Returns the list of lexed tokens."""
    return self.tokens


  def lex_regex(self):
    """Lexes the input stream to extract a list of tokens."""
    i = 0
    while i < len(self.regex):
      tok = None
      # Find the longest token match in the stream
      for cand in list(self.TOKEN_MAP):
        tok = self.regex[i:i + len(cand)]
        if tok == cand:
          tok = cand
          break
      
      if not tok:
        tok = self.regex[i]
      i += len(tok)
      self.tokens.append(tok)
    if self.verbose:
      print("INFO: Token list: ", self.tokens)
    return self.tokens


  def parse_tokens(self):
    """Parses the regex token list and emits a graph of states."""
    stack = []
    state = "RUN"
    scratch = ""
    for i in range(len(self.tokens)):
      tok = self.tokens[i]
      if tok == "[":
        # Need to wait for ending bracket
        scratch = tok
        state = "WAIT_FOR_BRACKET_SQUARE_CLOS"
      elif state == "WAIT_FOR_BRACKET_SQUARE_CLOS":
        scratch += tok
        if tok == "]":
          stack.append(("LITERAL", scratch))
          # Increment stack pointer
          state = "RUN"
          scratch = ""
      elif tok.isalnum():
        stack.append(("LITERAL", tok))
      else:
        stack.append(("COMMAND", tok))

    if self.verbose:
      print("INFO: Command stack:", stack)

    # Construct the regex "syntax tree", which forms the basis of the NFA graph
    nfa_stack = []
    for i in range(len(stack)-1):
      # Lookahead by one parser loop
      cmd = stack[i]
      cmd_next = stack[i+1]
      cmd_type = cmd[0]
      cmd_data = cmd[1]
      st = NFAState(cmd_data)
      if len(nfa_stack) == 0:
        nfa_stack.append(st)
      elif cmd_type == "LITERAL":
        nfa_stack[-1].add_neighbor(st)
      elif cmd_type == "COMMAND":
        nfa_stack.append(st)
        
    print([str(n) for n in nfa_stack])


  def construct_nfa(self):
    """Uses a modification of Thompson's algorithm to create finite automata."""
    if self.verbose:
      print(f"INFO: Constructing NFA for \"{self.regex}\"")

    self.lex_regex()
    self.parse_tokens()


def validate_regex(regex_list):
  """Dummy function to validate regex."""
  # Nothing to validate yet, will need in the future.
  return True


def generate_regex_list(cml_regex, verbose=False):
  """Turn a regex or file list of regexes into expr list."""
  regex_list = []
  if os.path.isfile(cml_regex):
    with open(cml_regex, "r") as f:
      for line in f:
        regex_list.append(line.strip())
  else:
    regex_list = [cml_regex.strip()]
  if verbose:
    print("INFO: Regex list:")
    for re in regex_list:
      print("  ", re)
  return regex_list


def regex_parser_main():
  """Main entrypoint of regex_parser.py."""
  parser = argparse.ArgumentParser(description="Turn a regex into NFA.")
  parser.add_argument("regex", help="Regex or a file list of regexes.")
  parser.add_argument("-v", "--verbose", help="Verbose mode.",
      action="store_true", required=False)
  args = parser.parse_args()

  regexes = generate_regex_list(args.regex, verbose=args.verbose)
  if not validate_regex(regexes):
    print("ERROR: Invalid regex(es) detected!", file=sys.stderr)
    exit(1)

  parser_list = [RegexParser(re, verbose=args.verbose) for re in regexes]


if __name__ == "__main__":
  regex_parser_main()
