!function(e){function n(n){for(var a,o,l=n[0],s=n[1],c=n[2],m=0,d=[];m<l.length;m++)o=l[m],Object.prototype.hasOwnProperty.call(r,o)&&r[o]&&d.push(r[o][0]),r[o]=0;for(a in s)Object.prototype.hasOwnProperty.call(s,a)&&(e[a]=s[a]);for(u&&u(n);d.length;)d.shift()();return i.push.apply(i,c||[]),t()}function t(){for(var e,n=0;n<i.length;n++){for(var t=i[n],a=!0,l=1;l<t.length;l++){var s=t[l];0!==r[s]&&(a=!1)}a&&(i.splice(n--,1),e=o(o.s=t[0]))}return e}var a={},r={0:0},i=[];function o(n){if(a[n])return a[n].exports;var t=a[n]={i:n,l:!1,exports:{}};return e[n].call(t.exports,t,t.exports,o),t.l=!0,t.exports}o.m=e,o.c=a,o.d=function(e,n,t){o.o(e,n)||Object.defineProperty(e,n,{enumerable:!0,get:t})},o.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},o.t=function(e,n){if(1&n&&(e=o(e)),8&n)return e;if(4&n&&"object"==typeof e&&e&&e.__esModule)return e;var t=Object.create(null);if(o.r(t),Object.defineProperty(t,"default",{enumerable:!0,value:e}),2&n&&"string"!=typeof e)for(var a in e)o.d(t,a,function(n){return e[n]}.bind(null,a));return t},o.n=function(e){var n=e&&e.__esModule?function(){return e.default}:function(){return e};return o.d(n,"a",n),n},o.o=function(e,n){return Object.prototype.hasOwnProperty.call(e,n)},o.p="";var l=window.webpackJsonp=window.webpackJsonp||[],s=l.push.bind(l);l.push=n,l=l.slice();for(var c=0;c<l.length;c++)n(l[c]);var u=s;i.push([430,1]),t()}({223:function(e,n,t){},430:function(e,n,t){"use strict";t.r(n);var a,r,i,o,l,s,c=t(20),u=t(0),m=t.n(u),d=t(6),p=t.n(d),f=t(57),h=t(216),g=(t(223),t(61),t(18)),b=(t(152),t(86)),v=(t(226),t(88)),y=(t(91),t(31)),E=(t(92),t(48)),w=t(42),k=t(65),I=t.n(k),S=function(e,n){return Object.defineProperty?Object.defineProperty(e,"raw",{value:n}):e.raw=n,e},C=I()(a||(a=S(["\n  {\n    shoppingListItems {\n      _id\n      name\n      checked\n      assignee\n    }\n  }\n"],["\n  {\n    shoppingListItems {\n      _id\n      name\n      checked\n      assignee\n    }\n  }\n"]))),O=I()(r||(r=S(["\n  mutation createShoppingListItem($name: String!) {\n    createShoppingListItem(name: $name) {\n      _id\n      name\n      checked\n      assignee\n    }\n  }\n"],["\n  mutation createShoppingListItem($name: String!) {\n    createShoppingListItem(name: $name) {\n      _id\n      name\n      checked\n      assignee\n    }\n  }\n"]))),L=I()(i||(i=S(["\n  mutation deleteItem($id: ID!) {\n    deleteShoppingListItem(id: $id)\n  }\n"],["\n  mutation deleteItem($id: ID!) {\n    deleteShoppingListItem(id: $id)\n  }\n"]))),j=I()(o||(o=S(["\n  mutation updateItem($id: ID!, $state: Boolean, $assignee: String) {\n    updateShoppingListItem(id: $id, state: $state, assignee: $assignee) {\n      _id\n      name\n      checked\n      assignee\n    }\n  }\n"],["\n  mutation updateItem($id: ID!, $state: Boolean, $assignee: String) {\n    updateShoppingListItem(id: $id, state: $state, assignee: $assignee) {\n      _id\n      name\n      checked\n      assignee\n    }\n  }\n"]))),x=I()(l||(l=S(["\n  mutation clearList {\n    clearShoppingList\n  }\n"],["\n  mutation clearList {\n    clearShoppingList\n  }\n"]))),$=I()(s||(s=S(["\n  mutation login($username: String!, $password: String!) {\n    login(username: $username, password: $password) {\n      success\n      message\n    }\n  }\n"],["\n  mutation login($username: String!, $password: String!) {\n    login(username: $username, password: $password) {\n      success\n      message\n    }\n  }\n"])));function N(e){var n=Object(u.useState)(""),t=n[0],a=n[1],r=Object(u.useState)(""),i=r[0],o=r[1],l=Object(u.useState)(""),s=l[0],c=l[1],d=Object(w.a)($,{onCompleted:function(n){n.login.success?(c(""),e.onLoginSuccess()):c(n.login.message)},fetchPolicy:"no-cache"}),p=d[0],f=d[1].loading,h=""===t||""===i,k=function(){h||p({variables:{username:t,password:i}})};return m.a.createElement(E.a,{justify:"center",align:"middle",style:{height:"100%"}},m.a.createElement(y.a,null,m.a.createElement(v.a,{labelCol:{span:8},wrapperCol:{span:16}},m.a.createElement(v.a.Item,{label:"Nutzername:",required:!0,validateStatus:s?"error":"",hasFeedback:!0},m.a.createElement(b.a,{onChange:function(e){return a(e.target.value)},value:t,onPressEnter:k,disabled:f})),m.a.createElement(v.a.Item,{label:"Kennwort:",required:!0,help:s,validateStatus:s?"error":"",hasFeedback:!0},m.a.createElement(b.a.Password,{onChange:function(e){return o(e.target.value)},value:i,onPressEnter:k,disabled:f})),m.a.createElement(v.a.Item,{wrapperCol:{offset:8,span:16}},m.a.createElement(g.a,{type:"primary",onClick:k,disabled:h||f,loading:f},"Anmelden")))))}t(183);var _=t(111),P=(t(431),t(212)),A=(t(376),t(213)),D=(t(378),t(89)),T=(t(380),t(214)),q=(t(382),t(150)),z=t(434),B=t(435),Q=t(436),G=t(432),K=t(437),M=(t(186),t(119)),R=(t(143),t(60)),W=t(433),F=(t(388),t(200)),J=(t(390),t(217));var H,U=function(e,n,t,a){return new(t||(t=Promise))((function(r,i){function o(e){try{s(a.next(e))}catch(e){i(e)}}function l(e){try{s(a.throw(e))}catch(e){i(e)}}function s(e){var n;e.done?r(e.value):(n=e.value,n instanceof t?n:new t((function(e){e(n)}))).then(o,l)}s((a=a.apply(e,n||[])).next())}))},V=function(e,n){var t,a,r,i,o={label:0,sent:function(){if(1&r[0])throw r[1];return r[1]},trys:[],ops:[]};return i={next:l(0),throw:l(1),return:l(2)},"function"==typeof Symbol&&(i[Symbol.iterator]=function(){return this}),i;function l(i){return function(l){return function(i){if(t)throw new TypeError("Generator is already executing.");for(;o;)try{if(t=1,a&&(r=2&i[0]?a.return:i[0]?a.throw||((r=a.return)&&r.call(a),0):a.next)&&!(r=r.call(a,i[1])).done)return r;switch(a=0,r&&(i=[2&i[0],r.value]),i[0]){case 0:case 1:r=i;break;case 4:return o.label++,{value:i[1],done:!1};case 5:o.label++,a=i[1],i=[0];continue;case 7:i=o.ops.pop(),o.trys.pop();continue;default:if(!(r=o.trys,(r=r.length>0&&r[r.length-1])||6!==i[0]&&2!==i[0])){o=0;continue}if(3===i[0]&&(!r||i[1]>r[0]&&i[1]<r[3])){o.label=i[1];break}if(6===i[0]&&o.label<r[1]){o.label=r[1],r=i;break}if(r&&o.label<r[2]){o.label=r[2],o.ops.push(i);break}r[2]&&o.ops.pop(),o.trys.pop();continue}i=n.call(e,o)}catch(e){i=[6,e],a=0}finally{t=r=0}if(5&i[0])throw i[1];return{value:i[0]?i[1]:void 0,done:!0}}([i,l])}}};function X(e){var n=this,t=Object(u.useState)(e.item.assignee),a=t[0],r=t[1],i=e.assigneeCandidates?function(e){for(var n=new Set,t=[],a=0,r=e;a<r.length;a++){var i=r[a];n.has(i)||(t.push(i),n.add(i))}return t}(e.assigneeCandidates.filter((function(e){return e.startsWith(a)&&""!==e}))):[],o=function(){e.onItemAssigneeChange&&a!==e.item.assignee&&e.onItemAssigneeChange(a)},l=Object(u.useState)(!1),s=l[0],c=l[1];return m.a.createElement(M.a.Item,{className:"shopping-list-item",key:e.item._id,style:{textDecoration:e.item.checked?"line-through":"none"},onClick:function(){return e.onItemCheckedChange(!e.item.checked)}},m.a.createElement(E.a,{className:"shopping-list-item-row"},m.a.createElement(y.a,{span:20},m.a.createElement(J.a,{style:{marginRight:"1em"},checked:e.item.checked,onChange:function(n){return e.onItemCheckedChange(n.target.checked)}}),e.item.name,e.assigneeCandidates&&e.item.assignee?" kauft":"",e.assigneeCandidates&&m.a.createElement(F.a,{defaultActiveFirstOption:!0,value:a,onChange:r,onSelect:o,onClick:function(e){e.stopPropagation()},onInputKeyDown:function(e){13===e.keyCode&&o()},onBlur:o,placeholder:"Wer kauf das?",options:i.map((function(e){return{value:e}})),bordered:!1,size:"small",style:{minWidth:"30%"}})),m.a.createElement(y.a,{span:4},m.a.createElement(g.a,{key:"delete-item-btn",type:"dashed",size:"small",loading:s,onClick:function(t){return U(n,void 0,void 0,(function(){return V(this,(function(n){switch(n.label){case 0:return t.stopPropagation(),c(!0),[4,e.onItemDeleted()];case 1:return n.sent(),c(!1),[2]}}))}))},"data-testid":"delete-item-btn",className:"delete-item-btn"},s?m.a.createElement("div",null):m.a.createElement(G.a,{alt:"Eintrag entfernen"})))))}!function(e){e[e.all=0]="all",e[e.checked=1]="checked",e[e.unchecked=2]="unchecked"}(H||(H={}));var Y=function(e){var n=e.shoppingList.filter((function(n){switch(e.filter){case H.all:return!0;case H.checked:return n.checked;case H.unchecked:return!n.checked}}));return 0===n.length?m.a.createElement(R.a,{description:"Kaufstu was!?",image:m.a.createElement(W.a,{style:{fontSize:"6em"}}),className:e.className}):m.a.createElement(M.a,{className:e.className,dataSource:n,size:"small",renderItem:function(n){return m.a.createElement(X,{item:n,assigneeCandidates:e.assigneeCandidates,onItemCheckedChange:function(t){return e.onItemCheckedChange(n,t)},onItemDeleted:function(){return e.onItemDeleted(n)},onItemAssigneeChange:function(t){e.onItemAssigneeChange&&e.onItemAssigneeChange(n,t)}})}})},Z=function(e,n,t,a){return new(t||(t=Promise))((function(r,i){function o(e){try{s(a.next(e))}catch(e){i(e)}}function l(e){try{s(a.throw(e))}catch(e){i(e)}}function s(e){var n;e.done?r(e.value):(n=e.value,n instanceof t?n:new t((function(e){e(n)}))).then(o,l)}s((a=a.apply(e,n||[])).next())}))},ee=function(e,n){var t,a,r,i,o={label:0,sent:function(){if(1&r[0])throw r[1];return r[1]},trys:[],ops:[]};return i={next:l(0),throw:l(1),return:l(2)},"function"==typeof Symbol&&(i[Symbol.iterator]=function(){return this}),i;function l(i){return function(l){return function(i){if(t)throw new TypeError("Generator is already executing.");for(;o;)try{if(t=1,a&&(r=2&i[0]?a.return:i[0]?a.throw||((r=a.return)&&r.call(a),0):a.next)&&!(r=r.call(a,i[1])).done)return r;switch(a=0,r&&(i=[2&i[0],r.value]),i[0]){case 0:case 1:r=i;break;case 4:return o.label++,{value:i[1],done:!1};case 5:o.label++,a=i[1],i=[0];continue;case 7:i=o.ops.pop(),o.trys.pop();continue;default:if(!(r=o.trys,(r=r.length>0&&r[r.length-1])||6!==i[0]&&2!==i[0])){o=0;continue}if(3===i[0]&&(!r||i[1]>r[0]&&i[1]<r[3])){o.label=i[1];break}if(6===i[0]&&o.label<r[1]){o.label=r[1],r=i;break}if(r&&o.label<r[2]){o.label=r[2],o.ops.push(i);break}r[2]&&o.ops.pop(),o.trys.pop();continue}i=n.call(e,o)}catch(e){i=[6,e],a=0}finally{t=r=0}if(5&i[0])throw i[1];return{value:i[0]?i[1]:void 0,done:!0}}([i,l])}}};var ne=function(e){var n=this,t=Object(u.useState)(""),a=t[0],r=t[1],i=Object(u.useState)(!1),o=i[0],l=i[1],s=e.shoppingList.map((function(e){return e.assignee})),c=function(){return Z(n,void 0,void 0,(function(){return ee(this,(function(n){switch(n.label){case 0:return""===a?[2]:(l(!0),[4,e.onCreateNewItem(a)]);case 1:return n.sent(),r(""),l(!1),[2]}}))}))};return m.a.createElement("div",{className:"editable-shopping-list-component"},m.a.createElement(Y,{className:"editable-shopping-list-component-list",shoppingList:e.shoppingList,filter:e.filter,assigneeCandidates:s,onItemAssigneeChange:e.onItemAssigneeChange,onItemCheckedChange:e.onItemCheckedChange,onItemDeleted:e.onItemDeleted}),m.a.createElement("div",{className:"editable-shopping-list-component-controls"},m.a.createElement(E.a,{gutter:[16,8]},m.a.createElement(y.a,{xs:20,sm:20,md:20,lg:20,xl:20},m.a.createElement(b.a,{value:a,onChange:function(e){return r(e.target.value)},onPressEnter:c,disabled:o})),m.a.createElement(y.a,{xs:0,sm:0,md:4,lg:4,xl:4},m.a.createElement(g.a,{type:"primary",style:{width:"100%"},disabled:""===a,onClick:c,loading:o},"Hinzufügen")),m.a.createElement(y.a,{xs:4,sm:4,md:0,lg:0,xl:0},m.a.createElement(g.a,{className:"editable-shopping-list-small-add-button",type:"primary",disabled:""===a,onClick:c,loading:o},o?"":"+")))))},te=function(e,n,t,a){return new(t||(t=Promise))((function(r,i){function o(e){try{s(a.next(e))}catch(e){i(e)}}function l(e){try{s(a.throw(e))}catch(e){i(e)}}function s(e){var n;e.done?r(e.value):(n=e.value,n instanceof t?n:new t((function(e){e(n)}))).then(o,l)}s((a=a.apply(e,n||[])).next())}))},ae=function(e,n){var t,a,r,i,o={label:0,sent:function(){if(1&r[0])throw r[1];return r[1]},trys:[],ops:[]};return i={next:l(0),throw:l(1),return:l(2)},"function"==typeof Symbol&&(i[Symbol.iterator]=function(){return this}),i;function l(i){return function(l){return function(i){if(t)throw new TypeError("Generator is already executing.");for(;o;)try{if(t=1,a&&(r=2&i[0]?a.return:i[0]?a.throw||((r=a.return)&&r.call(a),0):a.next)&&!(r=r.call(a,i[1])).done)return r;switch(a=0,r&&(i=[2&i[0],r.value]),i[0]){case 0:case 1:r=i;break;case 4:return o.label++,{value:i[1],done:!1};case 5:o.label++,a=i[1],i=[0];continue;case 7:i=o.ops.pop(),o.trys.pop();continue;default:if(!(r=o.trys,(r=r.length>0&&r[r.length-1])||6!==i[0]&&2!==i[0])){o=0;continue}if(3===i[0]&&(!r||i[1]>r[0]&&i[1]<r[3])){o.label=i[1];break}if(6===i[0]&&o.label<r[1]){o.label=r[1],r=i;break}if(r&&o.label<r[2]){o.label=r[2],o.ops.push(i);break}r[2]&&o.ops.pop(),o.trys.pop();continue}i=n.call(e,o)}catch(e){i=[6,e],a=0}finally{t=r=0}if(5&i[0])throw i[1];return{value:i[0]?i[1]:void 0,done:!0}}([i,l])}}},re=function(){for(var e=0,n=0,t=arguments.length;n<t;n++)e+=arguments[n].length;var a=Array(e),r=0;for(n=0;n<t;n++)for(var i=arguments[n],o=0,l=i.length;o<l;o++,r++)a[r]=i[o];return a},ie=q.a.TabPane;var oe=function(e){var n=this,t=function(n){e.onAuthenticationError&&n.graphQLErrors.find((function(e){var n;return 401===(null===(n=null==e?void 0:e.extensions)||void 0===n?void 0:n.code)}))?e.onAuthenticationError():T.a.error({message:n.networkError?"Uuups ein Fehler ist aufgetreten...":n.name,description:n.networkError?"Der Server antwortet nicht :(":n.message})},a=Object(w.b)(C,{onError:t}),r=a.loading,i=a.data,o=i?i.shoppingListItems.length:0,l=Object(u.useRef)(!1),s=Object(u.useRef)(null),c=Object(w.a)(O,{onError:t,update:function(e,n){var t=n.data.createShoppingListItem,a=e.readQuery({query:C}).shoppingListItems;e.writeQuery({query:C,data:{shoppingListItems:re(a,[t])}}),l.current=!0}})[0];Object(u.useEffect)((function(){if(l.current&&null!==s.current){var e=s.current.getElementsByClassName("shopping-list-item");e.length>0&&e[e.length-1].scrollIntoView({behavior:"smooth"}),l.current=!1}}),[o]);var d,p=Object(w.a)(j,{onError:t})[0],f=Object(w.a)(L,{onError:t,update:function(e,n){var t=n.data.deleteShoppingListItem,a=e.readQuery({query:C}).shoppingListItems;e.writeQuery({query:C,data:{shoppingListItems:a.filter((function(e){return e._id!==t}))}})}})[0],h=Object(w.a)(x,{onError:t,update:function(e){e.writeQuery({query:C,data:{shoppingListItems:[]}})}})[0],b=(null==i?void 0:i.shoppingListItems)||[],v=function(e,n,t){for(var a=new Map,r=0,i=e;r<i.length;r++){var o=i[r],l=n(o),s=t(o),c=a.get(l);c?c.push(s):a.set(l,[s])}return a}(b.filter((function(e){return!!e.assignee})),(function(e){return e.assignee}),(function(e){return e})),k=Array.from(v.entries()),I=function(e,n){p({variables:{id:e._id,state:n},optimisticResponse:{updateShoppingListItem:{__typename:"ShoppingListItem",_id:e._id,assignee:e.assignee,name:e.name,checked:n}}})},S=function(e){return te(n,void 0,void 0,(function(){return ae(this,(function(n){switch(n.label){case 0:return[4,f({variables:{id:e._id}})];case 1:return n.sent(),[2]}}))}))},$=Object(u.useState)("main"),N=$[0],M=$[1],R=Object(u.useState)(H.all),W=R[0],F=R[1],J=function(){return m.a.createElement(D.a.Group,{buttonStyle:"solid",size:"small",value:W,onChange:function(e){return F(e.target.value)}},m.a.createElement(D.a.Button,{value:H.all},m.a.createElement(z.a,null)),m.a.createElement(D.a.Button,{value:H.checked},m.a.createElement(B.a,null)),m.a.createElement(D.a.Button,{value:H.unchecked},m.a.createElement(Q.a,null)))},U=function(){return"main"!==N?m.a.createElement("div",null):m.a.createElement(g.a,{danger:!0,type:"default",size:"small",onClick:function(){A.a.confirm({title:"Wollen Sie die Einkaufsliste wirklich leeren?",onOk:function(){return h()},okText:"Ja",cancelText:"Nein",icon:m.a.createElement(G.a,{style:{color:"#555555"}}),okType:"danger"})}},m.a.createElement(K.a,null))};return m.a.createElement("div",{className:"shopping-list-board"},m.a.createElement(P.a,{title:m.a.createElement("span",null,m.a.createElement("img",{className:"kaufhansel-image",src:"favicon.svg"}),m.a.createElement("span",null,"Kaufhansel")),subTitle:(d=v.get(N)||b,d.filter((function(e){return!e.checked})).length+"/"+d.length),className:"shopping-list-board-header",extra:m.a.createElement(E.a,{gutter:4},m.a.createElement(y.a,null,U()),m.a.createElement(y.a,null,J()))}),m.a.createElement(_.a,{spinning:r,tip:"Wird aktualisiert...",wrapperClassName:"shopping-list-board-spinner"},m.a.createElement(q.a,{defaultActiveKey:"main",activeKey:N,onChange:M,className:"shopping-list-board-tabs",animated:!1},m.a.createElement(ie,{tab:"Alle",key:"main"},m.a.createElement("div",{ref:s,className:"shopping-list-board-main-tab-content"},m.a.createElement(ne,{shoppingList:b,filter:W,onItemAssigneeChange:function(e,n){p({variables:{id:e._id,assignee:n}})},onItemCheckedChange:I,onItemDeleted:S,onCreateNewItem:function(e){return te(n,void 0,void 0,(function(){return ae(this,(function(n){switch(n.label){case 0:return[4,c({variables:{name:e}})];case 1:return n.sent(),[2]}}))}))}}))),k.map((function(e){var n=e[0],t=e[1];return m.a.createElement(ie,{tab:n,key:n},m.a.createElement(Y,{className:"shopping-list-board-readonly-list",shoppingList:t,filter:W,onItemCheckedChange:I,onItemDeleted:S}))})))))},le=t(58),se=t(215),ce=t(19),ue=t(208),me=t(218),de=t(207),pe=new le.c({cache:new se.a,link:ce.a.from([new de.a({delay:{initial:300,max:5e3,jitter:!0},attempts:{max:1/0,retryIf:function(e){return!!e}}}),Object(ue.a)((function(e){var n=e.graphQLErrors,t=e.networkError;console.log(n,t)})),new me.a({uri:"/graphql"})])});p.a.render(m.a.createElement(m.a.StrictMode,null,m.a.createElement(c.a,{client:pe},m.a.createElement(h.a,null,m.a.createElement((function(){var e=Object(u.useState)(document.cookie.includes("SHOPPER_LOGGED_IN=true")),n=e[0],t=e[1],a=Object(f.g)();return m.a.createElement(f.d,null,m.a.createElement(f.b,{path:"/login"},m.a.createElement(N,{onLoginSuccess:function(){t(!0),a.replace("/")}})),m.a.createElement(f.b,{path:"/",render:function(e){var a=e.location;return n?m.a.createElement(oe,{onAuthenticationError:function(){return t(!1)}}):m.a.createElement(f.a,{to:{pathname:"/login",state:{from:a}}})}}))}),null)))),document.getElementById("root"))}});
//# sourceMappingURL=main.js.map