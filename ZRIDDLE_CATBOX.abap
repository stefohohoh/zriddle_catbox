*&---------------------------------------------------------------------*
*& Report ZRIDDLE_CATBOX
*&---------------------------------------------------------------------*
*& A cat is hiding in one of the N boxes entered, lined up in a row.
*& Each night the cat hides in an adjacent box, exactly one number away.
*& Each morning you can open a single box to try to find the cat.
*&
*& This program implement a scheme for a dynamic solution, valid for any
*& number of boxes chosen.
*&---------------------------------------------------------------------*
REPORT zriddle_catbox.

TYPES: BEGIN OF box,
         boxno TYPE i,
         cat   TYPE flag.
TYPES: END OF box.

DATA: gt_boxes TYPE TABLE OF box,
      gs_boxes TYPE box.

DATA: gv_boxno  TYPE i,
      gv_cat    TYPE i,
      gv_found  TYPE flag,
      gv_check  TYPE i VALUE 1,
      gv_last   TYPE flag,
      gv_repeat TYPE flag,
      gv_day    TYPE i.

PARAMETERS: p_boxes TYPE i DEFAULT 5.

START-OF-SELECTION.

*Initialize Boxes
** Indexes
  CLEAR gv_boxno.
  DO p_boxes TIMES.
    ADD 1 TO gv_boxno.
    gs_boxes-boxno = gv_boxno.
    APPEND gs_boxes TO gt_boxes.
  ENDDO.


*** START RIDDLE ***

  WHILE gv_found IS INITIAL.

    PERFORM night.

    PERFORM day.

  ENDWHILE.

*&---------------------------------------------------------------------*
*& Form NIGHT
*&---------------------------------------------------------------------*
*& The cat moves by 1 box every night. If it reaches a corner, he can
*& go either only back or only forward.
*&---------------------------------------------------------------------*
FORM night .

  DATA: lv_pre  TYPE i,
        lv_post TYPE i.

*First Positioning
  IF gv_cat IS INITIAL.
    PERFORM shift_cat USING 1 p_boxes.
    RETURN.
  ENDIF.

*Begin of the Row of Boxes
  IF gv_cat EQ 1.
    gv_cat = 2.
    RETURN.
  ENDIF.

*End of the Row of Boxes
  IF gv_cat EQ p_boxes.
    gv_cat = p_boxes - 1.
    RETURN.
  ENDIF.

*Somewhere in the middle
  lv_pre = gv_cat - 1.
  lv_post = gv_cat + 1.

  PERFORM shift_cat USING lv_pre lv_post.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DAY
*&---------------------------------------------------------------------*
*& Each day, the player checks in which box the cat may be.
*& The solution to this riddle is to check the boxes starting from the
*& second one, and proceed to the second-to-last box: in that moment,
*& the search scheme reverts so it starts again from the second-to-last
*& box and goes until the second. The cat is found between these steps.
*&---------------------------------------------------------------------*
FORM day .

  DATA: txt_day   TYPE string,
        txt_check TYPE string.

  ADD 1 TO gv_day.

  IF gv_last IS INITIAL.
    ADD 1 TO gv_check.
  ELSE.
    IF gv_repeat IS INITIAL.
      gv_repeat = 'X'.
    ELSE.
      IF gv_check GT 2.
        SUBTRACT 1 FROM gv_check.
      ELSE.
        CLEAR: gv_last, gv_repeat.
      ENDIF.
    ENDIF.
  ENDIF.

  IF gv_check EQ p_boxes - 1.
    gv_last = 'X'.
  ENDIF.

  txt_day = gv_day.
  txt_check = gv_check.

  READ TABLE gt_boxes INTO gs_boxes WITH KEY boxno = gv_check.

  IF gs_boxes-cat IS INITIAL.
    WRITE:/ 'Day', txt_day NO-GAP, ': I checked Box #', txt_check NO-GAP, ', cat not found.'.
  ELSE.
    gv_found = 'X'.
    WRITE:/ 'Day', txt_day NO-GAP, ': I checked Box #', txt_check NO-GAP, ', and I found the cat!'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SHIFT_CAT
*&---------------------------------------------------------------------*
*& Simple form that generates a random position of the cat, whether it
*& is the very first positioning or the normal moving between the nights
*&---------------------------------------------------------------------*
FORM shift_cat  USING low high.

  DATA: lv_move TYPE i.

  lv_move = gv_cat.

*Clean Cat's Previous Position from Main Table
  READ TABLE gt_boxes INTO gs_boxes WITH KEY cat = 'X'.
  CLEAR gs_boxes-cat.
  MODIFY gt_boxes FROM gs_boxes INDEX gs_boxes-boxno.

*Generate Random Number Between Form Limits
  WHILE gv_cat EQ lv_move.
    CALL FUNCTION 'QF05_RANDOM_INTEGER'
      EXPORTING
        ran_int_max = high
        ran_int_min = low
      IMPORTING
        ran_int     = lv_move.
  ENDWHILE.

  gv_cat = lv_move.

*Place Cat In Box #^•#•^#
  READ TABLE gt_boxes INTO gs_boxes WITH KEY boxno = gv_cat.
  gs_boxes-cat = 'X'.
  MODIFY gt_boxes FROM gs_boxes INDEX gs_boxes-boxno.

ENDFORM.
