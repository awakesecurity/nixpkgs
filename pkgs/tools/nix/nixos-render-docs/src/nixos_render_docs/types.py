from collections.abc import Sequence, MutableMapping
from typing import Any, Callable, Optional, Tuple, NamedTuple

from markdown_it.token import Token
from markdown_it.utils import OptionsDict

OptionLoc = str | dict[str, str]
Option = dict[str, str | dict[str, str] | list[OptionLoc]]

class RenderedOption(NamedTuple):
    loc: list[str]
    lines: list[str]
    links: Optional[list[str]] = None

RenderFn = Callable[[Token, Sequence[Token], int, OptionsDict, MutableMapping[str, Any]], str]
