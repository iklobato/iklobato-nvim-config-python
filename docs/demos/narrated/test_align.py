"""Checks for the parts of align.py that decide where a line of voice lands."""

from align import LEAD, MIN_GAP, CutChooser, Placer, Span

FIRST_LINE_END = 4.0
SECOND_LINE_END = 6.0
EARLY_ONSET = 2.0
LATE_ONSET = 5.0
SHORT_PAUSE = (1.0, 1.1)
LONG_PAUSE = (1.3, 1.7)
FAR_PAUSE = (9.0, 9.9)
GAP_NEAR_PAUSES = (1.2, 1.4)
GAP_WITHOUT_PAUSE = (5.0, 5.2)


def test_a_line_that_would_overlap_waits_for_the_previous_one() -> None:
    first, second = Span(0.0, FIRST_LINE_END), Span(FIRST_LINE_END, SECOND_LINE_END)

    placed = Placer().plan([first, second], [0.0, EARLY_ONSET])

    second_start = first.end + MIN_GAP
    assert placed == [first, Span(second_start, second_start + second.length())]


def test_a_free_line_starts_lead_seconds_before_its_step() -> None:
    line = Span(FIRST_LINE_END, SECOND_LINE_END)

    placed = Placer().plan([line], [LATE_ONSET])

    assert placed == [Span(LATE_ONSET - LEAD, LATE_ONSET - LEAD + line.length())]


def test_the_cut_goes_in_the_middle_of_the_longest_nearby_pause() -> None:
    pauses = [Span(*SHORT_PAUSE), Span(*LONG_PAUSE), Span(*FAR_PAUSE)]

    cut = CutChooser().cut(Span(*GAP_NEAR_PAUSES), pauses)

    assert cut == Span(*LONG_PAUSE).middle()


def test_with_no_pause_near_the_gap_the_cut_goes_in_its_middle() -> None:
    pauses = [Span(*SHORT_PAUSE), Span(*LONG_PAUSE), Span(*FAR_PAUSE)]

    cut = CutChooser().cut(Span(*GAP_WITHOUT_PAUSE), pauses)

    assert cut == Span(*GAP_WITHOUT_PAUSE).middle()
