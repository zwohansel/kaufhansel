INSERT INTO ITEMS (LIST_ID, NAME, CHECKED, POSITION)
VALUES ((SELECT ID FROM LISTS WHERE NAME = 'Alice List'), 'Test Item', 0, 0);