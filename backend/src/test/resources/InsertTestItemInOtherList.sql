INSERT INTO ITEMS (LIST_ID, NAME, CHECKED, POSITION)
VALUES ((SELECT ID FROM LISTS WHERE NAME = 'Other List'), 'Other Test Item', 0, 0);
