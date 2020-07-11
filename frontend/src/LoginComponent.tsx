import { useMutation } from "@apollo/react-hooks";
import { Button, Col, Form, Input, Row } from "antd";
import React, { useState } from "react";
import { LOGIN, LoginData, LoginVariables } from "./GraphQLDefinitions";

export interface LoginComponentProps {
  onLoginSuccess: (userId: string) => void;
}

export default function LoginComponent(props: LoginComponentProps) {
  const [username, setUserName] = useState("");
  const [password, setPassword] = useState("");
  const [loginError, setLoginError] = useState("");

  const [doLogin, { loading }] = useMutation<LoginData, LoginVariables>(LOGIN, {
    onCompleted: data => {
      if (data.login.success) {
        setLoginError("");
        props.onLoginSuccess(data.login.data as string);
      } else {
        setLoginError(data.login.message);
      }
    },
    fetchPolicy: "no-cache"
  });

  const credentialsEmpty = username === "" || password === "";

  const login = () => {
    if (credentialsEmpty) {
      return;
    }
    doLogin({ variables: { username, password } });
  };

  return (
    <Row justify={"center"} align={"middle"} style={{ height: "100%" }}>
      <Col>
        <Form labelCol={{ span: 8 }} wrapperCol={{ span: 16 }}>
          <Form.Item label={"Nutzername:"} required={true} validateStatus={loginError ? "error" : ""} hasFeedback>
            <Input
              onChange={event => setUserName(event.target.value)}
              value={username}
              onPressEnter={login}
              disabled={loading}
            />
          </Form.Item>
          <Form.Item
            label={"Kennwort:"}
            required={true}
            help={loginError}
            validateStatus={loginError ? "error" : ""}
            hasFeedback
          >
            <Input.Password
              onChange={event => setPassword(event.target.value)}
              value={password}
              onPressEnter={login}
              disabled={loading}
            />
          </Form.Item>
          <Form.Item wrapperCol={{ offset: 8, span: 16 }}>
            <Button type="primary" onClick={login} disabled={credentialsEmpty || loading} loading={loading}>
              Anmelden
            </Button>
          </Form.Item>
        </Form>
      </Col>
    </Row>
  );
}
