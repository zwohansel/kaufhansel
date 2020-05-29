import { DeleteFilled } from "@ant-design/icons";
import { Button, Checkbox, Col, Input, List, Modal, Row } from "antd";
import React, { Fragment, useState } from "react";
import { ShoppingListItem } from "./ShoppingListItem";
import { unique } from "./utils";

export interface ShoppingListItemComponentProps {
  item: ShoppingListItem;
  assigneeCandidates?: string[];
  onItemCheckedChange: (checked: boolean) => void;
  onItemDeleted: () => Promise<void>;
  onItemAssigneeChange?: (assignee: string) => void;
}

export function ShoppingListItemComponent(props: ShoppingListItemComponentProps) {
  const assigneeCandidates = props.assigneeCandidates ? unique(props.assigneeCandidates.filter(e => e !== "")) : [];

  const [deletingItem, setDeletingItem] = useState(false);
  const [newAssignee, setNewAssignee] = useState("");
  const [showNewAssigneeSelection, setShowNewAssigneeSelection] = useState(false);

  const handleAssigneeSelectionOk = () => {
    setShowNewAssigneeSelection(false);

    if (props.onItemAssigneeChange) {
      props.onItemAssigneeChange(newAssignee);
    }
  };

  const handleAssigneeSelectionCancel = () => {
    setShowNewAssigneeSelection(false);
  };

  return (
    <Fragment>
      <List.Item
        className="shopping-list-item"
        key={props.item._id}
        style={{
          textDecoration: props.item.checked ? "line-through" : "none"
        }}
        onClick={() => props.onItemCheckedChange(!props.item.checked)}
      >
        <Row className="shopping-list-item-row">
          <Col span={20}>
            <Checkbox style={{ marginRight: "1em" }} checked={props.item.checked} />
            {props.item.name}
            {props.assigneeCandidates && props.item.assignee ? " kauft" : ""}
            {props.assigneeCandidates && (
              <span
                className={
                  "assignee-candidate" +
                  (props.item.assignee === "" ? " assignee-candidate-placeholder" : " assignee-candidate-set")
                }
                onClick={e => {
                  e.stopPropagation();
                  setNewAssignee("");
                  setShowNewAssigneeSelection(true);
                }}
              >
                {props.item.assignee === "" ? "Wer kauft das?" : props.item.assignee}
              </span>
            )}
          </Col>
          <Col span={4}>
            <Button
              key="delete-item-btn"
              type="dashed"
              size="small"
              loading={deletingItem}
              onClick={async e => {
                e.stopPropagation();
                setDeletingItem(true);
                await props.onItemDeleted();
                setDeletingItem(false);
              }}
              data-testid="delete-item-btn"
              className="delete-item-btn"
            >
              {deletingItem ? <div /> : <DeleteFilled alt={"Eintrag entfernen"} />}
            </Button>
          </Col>
        </Row>
      </List.Item>
      <Modal
        title={
          <div>
            <span>Wer kauft das?</span>
            <span className="assignee-select-dialog-subtitle">Wählstu oder sagstu!</span>
          </div>
        }
        visible={showNewAssigneeSelection}
        okButtonProps={{ disabled: newAssignee === "" }}
        onOk={handleAssigneeSelectionOk}
        onCancel={handleAssigneeSelectionCancel}
        footer={[
          <Button key="cancel" onClick={handleAssigneeSelectionCancel}>
            Egal
          </Button>,
          <Button
            key="delete"
            danger
            disabled={props.item.assignee === ""}
            onClick={() => {
              setShowNewAssigneeSelection(false);

              if (props.onItemAssigneeChange) {
                props.onItemAssigneeChange("");
              }
            }}
          >
            Niemand
          </Button>,
          <Button key="ok" type="primary" onClick={handleAssigneeSelectionOk}>
            Zuweisen
          </Button>
        ]}
      >
        {assigneeCandidates.length !== 0 ? (
          <List
            dataSource={assigneeCandidates}
            split={false}
            renderItem={assignee => (
              <List.Item
                className={"assignee-candidate-item" + (props.item.assignee === assignee ? " current-candidate" : "")}
                key={assignee}
                onClick={() => {
                  setShowNewAssigneeSelection(false);

                  if (props.onItemAssigneeChange) {
                    props.onItemAssigneeChange(assignee);
                  }
                }}
              >
                {assignee}
              </List.Item>
            )}
          />
        ) : (
          <div />
        )}
        <Input
          placeholder={"Sagstu!"}
          value={newAssignee}
          onChange={e => setNewAssignee(e.target.value)}
          onPressEnter={handleAssigneeSelectionOk}
        />
      </Modal>
    </Fragment>
  );
}
