"""Checks for the parts of polish.py that decide what the viewer sees."""

import pytest

from polish import TITLE_MAX_CHARS, CardError, Framing, SvgCard, ZoomCurve, ZOOM_MOVE

WHOLE_SPOT = (700, 410, 1.0)
CLOSE_SPOT = (420, 240, 1.6)
HALVES = 2
STEP_ONE = 10.0
HALF_WAY = STEP_ONE + ZOOM_MOVE / 2
CARD_TEXT = (
    ("label", "Chapter"),
    ("problem", "A problem."),
    ("before", "b"),
    ("after", "a"),
)


class FfmpegExpression:
    """Evaluates the subset of ffmpeg expression syntax ZoomCurve writes."""

    def value(self, expression: str, at: float) -> float:
        names = {
            "it": at,
            "iff": lambda test, yes, no: yes if test else no,
            "lt": lambda left, right: left < right,
            "clip": lambda number, low, high: min(max(number, low), high),
        }
        return eval(expression.replace("if(", "iff("), {}, names)


def test_the_zoom_holds_the_framing_of_the_step_before_its_onset() -> None:
    curve = ZoomCurve([Framing(*WHOLE_SPOT), Framing(*CLOSE_SPOT)], [0.0, STEP_ONE])

    zoom = FfmpegExpression().value(curve.expression("zoom"), STEP_ONE - 1)

    assert zoom == WHOLE_SPOT[2]


def test_the_zoom_is_half_way_in_the_middle_of_its_move() -> None:
    curve = ZoomCurve([Framing(*WHOLE_SPOT), Framing(*CLOSE_SPOT)], [0.0, STEP_ONE])

    zoom = FfmpegExpression().value(curve.expression("zoom"), HALF_WAY)

    assert zoom == pytest.approx((WHOLE_SPOT[2] + CLOSE_SPOT[2]) / HALVES)


def test_the_zoom_lands_on_the_new_framing_after_its_move() -> None:
    curve = ZoomCurve([Framing(*WHOLE_SPOT), Framing(*CLOSE_SPOT)], [0.0, STEP_ONE])

    center_x = FfmpegExpression().value(
        curve.expression("center_x"), STEP_ONE + ZOOM_MOVE
    )

    assert center_x == CLOSE_SPOT[0]


def test_a_title_too_long_for_the_card_is_refused() -> None:
    long_title = "x" * (TITLE_MAX_CHARS + 1)

    with pytest.raises(
        CardError, match="card title has %d characters" % len(long_title)
    ):
        SvgCard().title({**dict(CARD_TEXT), "title": long_title})


def test_a_title_that_fits_is_drawn_on_the_card() -> None:
    svg = SvgCard().title({**dict(CARD_TEXT), "title": "x" * TITLE_MAX_CHARS})

    assert "x" * TITLE_MAX_CHARS in svg
