!function(e){function n(n){for(var a,o,s=n[0],l=n[1],c=n[2],m=0,d=[];m<s.length;m++)o=s[m],Object.prototype.hasOwnProperty.call(r,o)&&r[o]&&d.push(r[o][0]),r[o]=0;for(a in l)Object.prototype.hasOwnProperty.call(l,a)&&(e[a]=l[a]);for(u&&u(n);d.length;)d.shift()();return i.push.apply(i,c||[]),t()}function t(){for(var e,n=0;n<i.length;n++){for(var t=i[n],a=!0,s=1;s<t.length;s++){var l=t[s];0!==r[l]&&(a=!1)}a&&(i.splice(n--,1),e=o(o.s=t[0]))}return e}var a={},r={0:0},i=[];function o(n){if(a[n])return a[n].exports;var t=a[n]={i:n,l:!1,exports:{}};return e[n].call(t.exports,t,t.exports,o),t.l=!0,t.exports}o.m=e,o.c=a,o.d=function(e,n,t){o.o(e,n)||Object.defineProperty(e,n,{enumerable:!0,get:t})},o.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},o.t=function(e,n){if(1&n&&(e=o(e)),8&n)return e;if(4&n&&"object"==typeof e&&e&&e.__esModule)return e;var t=Object.create(null);if(o.r(t),Object.defineProperty(t,"default",{enumerable:!0,value:e}),2&n&&"string"!=typeof e)for(var a in e)o.d(t,a,function(n){return e[n]}.bind(null,a));return t},o.n=function(e){var n=e&&e.__esModule?function(){return e.default}:function(){return e};return o.d(n,"a",n),n},o.o=function(e,n){return Object.prototype.hasOwnProperty.call(e,n)},o.p="";var s=window.webpackJsonp=window.webpackJsonp||[],l=s.push.bind(s);s.push=n,s=s.slice();for(var c=0;c<s.length;c++)n(s[c]);var u=l;i.push([441,1]),t()}({228:function(e,n,t){},441:function(e,n,t){"use strict";t.r(n);var a,r,i,o,s,l,c,u=t(22),m=t(220),d=t(58),p=t(21),f=t(223),h=t(214),g=t(213),b=t(5),E=t(0),y=t.n(E),v=t(6),k=t.n(v),w=t(57),I=t(221),C=(t(228),t(62),t(17)),S=(t(128),t(65)),L=(t(231),t(90)),O=(t(94),t(32)),j=(t(95),t(50)),x=t(41),_=t(61),N=t.n(_),$=function(e,n){return Object.defineProperty?Object.defineProperty(e,"raw",{value:n}):e.raw=n,e},A=N()(a||(a=$(["\n  query shoppingListItems {\n    shoppingListItems {\n      _id\n      name\n      checked\n      assignee\n    }\n  }\n"],["\n  query shoppingListItems {\n    shoppingListItems {\n      _id\n      name\n      checked\n      assignee\n    }\n  }\n"]))),P=N()(r||(r=$(["\n  mutation createShoppingListItem($name: String!) {\n    createShoppingListItem(name: $name) {\n      _id\n      name\n      checked\n      assignee\n    }\n  }\n"],["\n  mutation createShoppingListItem($name: String!) {\n    createShoppingListItem(name: $name) {\n      _id\n      name\n      checked\n      assignee\n    }\n  }\n"]))),D=N()(i||(i=$(["\n  mutation deleteItem($id: ID!) {\n    deleteShoppingListItem(id: $id)\n  }\n"],["\n  mutation deleteItem($id: ID!) {\n    deleteShoppingListItem(id: $id)\n  }\n"]))),T=N()(o||(o=$(["\n  mutation updateItem($id: ID!, $state: Boolean, $assignee: String) {\n    updateShoppingListItem(id: $id, state: $state, assignee: $assignee) {\n      _id\n      name\n      checked\n      assignee\n    }\n  }\n"],["\n  mutation updateItem($id: ID!, $state: Boolean, $assignee: String) {\n    updateShoppingListItem(id: $id, state: $state, assignee: $assignee) {\n      _id\n      name\n      checked\n      assignee\n    }\n  }\n"]))),q=N()(s||(s=$(["\n  mutation clearList {\n    clearShoppingList\n  }\n"],["\n  mutation clearList {\n    clearShoppingList\n  }\n"]))),M=N()(l||(l=$(["\n  mutation login($username: String!, $password: String!) {\n    login(username: $username, password: $password) {\n      success\n      message\n    }\n  }\n"],["\n  mutation login($username: String!, $password: String!) {\n    login(username: $username, password: $password) {\n      success\n      message\n    }\n  }\n"]))),B=N()(c||(c=$(["\n  subscription shoppingListChanged {\n    shoppingListChanged {\n      item {\n        _id\n        assignee\n        checked\n        name\n      }\n      type\n    }\n  }\n"],["\n  subscription shoppingListChanged {\n    shoppingListChanged {\n      item {\n        _id\n        assignee\n        checked\n        name\n      }\n      type\n    }\n  }\n"])));function Q(e){var n=Object(E.useState)(""),t=n[0],a=n[1],r=Object(E.useState)(""),i=r[0],o=r[1],s=Object(E.useState)(""),l=s[0],c=s[1],u=Object(x.a)(M,{onCompleted:function(n){n.login.success?(c(""),e.onLoginSuccess()):c(n.login.message)},fetchPolicy:"no-cache"}),m=u[0],d=u[1].loading,p=""===t||""===i,f=function(){p||m({variables:{username:t,password:i}})};return y.a.createElement(j.a,{justify:"center",align:"middle",style:{height:"100%"}},y.a.createElement(O.a,null,y.a.createElement(L.a,{labelCol:{span:8},wrapperCol:{span:16}},y.a.createElement(L.a.Item,{label:"Nutzername:",required:!0,validateStatus:l?"error":"",hasFeedback:!0},y.a.createElement(S.a,{onChange:function(e){return a(e.target.value)},value:t,onPressEnter:f,disabled:d})),y.a.createElement(L.a.Item,{label:"Kennwort:",required:!0,help:l,validateStatus:l?"error":"",hasFeedback:!0},y.a.createElement(S.a.Password,{onChange:function(e){return o(e.target.value)},value:i,onPressEnter:f,disabled:d})),y.a.createElement(L.a.Item,{wrapperCol:{offset:8,span:16}},y.a.createElement(C.a,{type:"primary",onClick:f,disabled:p||d,loading:d},"Anmelden")))))}t(190);var z=t(122),G=(t(194),t(46)),R=(t(376),t(219)),F=(t(191),t(114)),K=(t(442),t(217)),W=(t(383),t(91)),H=(t(385),t(218)),J=(t(387),t(157)),U=t(445),V=t(446),Z=t(447),X=t(448),Y=t(449),ee=t(443),ne=t(450),te=t(451),ae=(t(193),t(79)),re=(t(147),t(60)),ie=t(444),oe=(t(393),t(222));var se,le=function(e,n,t,a){return new(t||(t=Promise))((function(r,i){function o(e){try{l(a.next(e))}catch(e){i(e)}}function s(e){try{l(a.throw(e))}catch(e){i(e)}}function l(e){var n;e.done?r(e.value):(n=e.value,n instanceof t?n:new t((function(e){e(n)}))).then(o,s)}l((a=a.apply(e,n||[])).next())}))},ce=function(e,n){var t,a,r,i,o={label:0,sent:function(){if(1&r[0])throw r[1];return r[1]},trys:[],ops:[]};return i={next:s(0),throw:s(1),return:s(2)},"function"==typeof Symbol&&(i[Symbol.iterator]=function(){return this}),i;function s(i){return function(s){return function(i){if(t)throw new TypeError("Generator is already executing.");for(;o;)try{if(t=1,a&&(r=2&i[0]?a.return:i[0]?a.throw||((r=a.return)&&r.call(a),0):a.next)&&!(r=r.call(a,i[1])).done)return r;switch(a=0,r&&(i=[2&i[0],r.value]),i[0]){case 0:case 1:r=i;break;case 4:return o.label++,{value:i[1],done:!1};case 5:o.label++,a=i[1],i=[0];continue;case 7:i=o.ops.pop(),o.trys.pop();continue;default:if(!(r=o.trys,(r=r.length>0&&r[r.length-1])||6!==i[0]&&2!==i[0])){o=0;continue}if(3===i[0]&&(!r||i[1]>r[0]&&i[1]<r[3])){o.label=i[1];break}if(6===i[0]&&o.label<r[1]){o.label=r[1],r=i;break}if(r&&o.label<r[2]){o.label=r[2],o.ops.push(i);break}r[2]&&o.ops.pop(),o.trys.pop();continue}i=n.call(e,o)}catch(e){i=[6,e],a=0}finally{t=r=0}if(5&i[0])throw i[1];return{value:i[0]?i[1]:void 0,done:!0}}([i,s])}}};function ue(e){var n=this,t=e.assigneeCandidates?function(e){for(var n=new Set,t=[],a=0,r=e;a<r.length;a++){var i=r[a];n.has(i)||(t.push(i),n.add(i))}return t}(e.assigneeCandidates.filter((function(e){return""!==e}))):[],a=Object(E.useState)(!1),r=a[0],i=a[1],o=Object(E.useState)(""),s=o[0],l=o[1],c=Object(E.useState)(!1),u=c[0],m=c[1],d=function(){m(!1),e.onItemAssigneeChange&&e.onItemAssigneeChange(s)},p=function(){m(!1)};return y.a.createElement(E.Fragment,null,y.a.createElement(ae.a.Item,{className:"shopping-list-item",key:e.item._id,style:{textDecoration:e.item.checked?"line-through":"none"},onClick:function(){return e.onItemCheckedChange(!e.item.checked)}},y.a.createElement(j.a,{className:"shopping-list-item-row"},y.a.createElement(O.a,{span:20},y.a.createElement(oe.a,{style:{marginRight:"1em"},checked:e.item.checked}),e.item.name,e.assigneeCandidates&&e.item.assignee?" kauft":"",e.assigneeCandidates&&y.a.createElement("span",{className:"assignee-candidate"+(""===e.item.assignee?" assignee-candidate-placeholder":" assignee-candidate-set"),onClick:function(e){e.stopPropagation(),l(""),m(!0)}},""===e.item.assignee?"Wer kauft das?":e.item.assignee)),y.a.createElement(O.a,{span:4},y.a.createElement(C.a,{key:"delete-item-btn",type:"dashed",size:"small",loading:r,onClick:function(t){return le(n,void 0,void 0,(function(){return ce(this,(function(n){switch(n.label){case 0:return t.stopPropagation(),i(!0),[4,e.onItemDeleted()];case 1:return n.sent(),i(!1),[2]}}))}))},"data-testid":"delete-item-btn",className:"delete-item-btn"},r?y.a.createElement("div",null):y.a.createElement(ee.a,{alt:"Eintrag entfernen"}))))),y.a.createElement(z.a,{title:y.a.createElement("div",null,y.a.createElement("span",null,"Wer kauft das?"),y.a.createElement("span",{className:"assignee-select-dialog-subtitle"},"Wählstu oder sagstu!")),visible:u,okButtonProps:{disabled:""===s},onOk:d,onCancel:p,footer:[y.a.createElement(C.a,{key:"cancel",onClick:p},"Egal"),y.a.createElement(C.a,{key:"delete",danger:!0,disabled:""===e.item.assignee,onClick:function(){m(!1),e.onItemAssigneeChange&&e.onItemAssigneeChange("")}},"Niemand"),y.a.createElement(C.a,{key:"ok",type:"primary",onClick:d},"Zuweisen")]},0!==t.length?y.a.createElement(ae.a,{dataSource:t,split:!1,renderItem:function(n){return y.a.createElement(ae.a.Item,{className:"assignee-candidate-item"+(e.item.assignee===n?" current-candidate":""),key:n,onClick:function(){m(!1),e.onItemAssigneeChange&&e.onItemAssigneeChange(n)}},n)}}):y.a.createElement("div",null),y.a.createElement(S.a,{placeholder:"Sagstu!",value:s,onChange:function(e){return l(e.target.value)},onPressEnter:d})))}!function(e){e[e.all=0]="all",e[e.checked=1]="checked",e[e.unchecked=2]="unchecked"}(se||(se={}));var me=function(e){var n=e.shoppingList.filter((function(n){switch(e.filter){case se.all:return!0;case se.checked:return n.checked;case se.unchecked:return!n.checked}}));return 0===n.length?y.a.createElement(re.a,{description:"Kaufstu was!?",image:y.a.createElement(ie.a,{style:{fontSize:"6em"}}),className:e.className}):y.a.createElement(ae.a,{className:e.className,dataSource:n,size:"small",renderItem:function(n){return y.a.createElement(ue,{item:n,assigneeCandidates:e.assigneeCandidates,onItemCheckedChange:function(t){return e.onItemCheckedChange(n,t)},onItemDeleted:function(){return e.onItemDeleted(n)},onItemAssigneeChange:function(t){e.onItemAssigneeChange&&e.onItemAssigneeChange(n,t)}})}})},de=function(e,n,t,a){return new(t||(t=Promise))((function(r,i){function o(e){try{l(a.next(e))}catch(e){i(e)}}function s(e){try{l(a.throw(e))}catch(e){i(e)}}function l(e){var n;e.done?r(e.value):(n=e.value,n instanceof t?n:new t((function(e){e(n)}))).then(o,s)}l((a=a.apply(e,n||[])).next())}))},pe=function(e,n){var t,a,r,i,o={label:0,sent:function(){if(1&r[0])throw r[1];return r[1]},trys:[],ops:[]};return i={next:s(0),throw:s(1),return:s(2)},"function"==typeof Symbol&&(i[Symbol.iterator]=function(){return this}),i;function s(i){return function(s){return function(i){if(t)throw new TypeError("Generator is already executing.");for(;o;)try{if(t=1,a&&(r=2&i[0]?a.return:i[0]?a.throw||((r=a.return)&&r.call(a),0):a.next)&&!(r=r.call(a,i[1])).done)return r;switch(a=0,r&&(i=[2&i[0],r.value]),i[0]){case 0:case 1:r=i;break;case 4:return o.label++,{value:i[1],done:!1};case 5:o.label++,a=i[1],i=[0];continue;case 7:i=o.ops.pop(),o.trys.pop();continue;default:if(!(r=o.trys,(r=r.length>0&&r[r.length-1])||6!==i[0]&&2!==i[0])){o=0;continue}if(3===i[0]&&(!r||i[1]>r[0]&&i[1]<r[3])){o.label=i[1];break}if(6===i[0]&&o.label<r[1]){o.label=r[1],r=i;break}if(r&&o.label<r[2]){o.label=r[2],o.ops.push(i);break}r[2]&&o.ops.pop(),o.trys.pop();continue}i=n.call(e,o)}catch(e){i=[6,e],a=0}finally{t=r=0}if(5&i[0])throw i[1];return{value:i[0]?i[1]:void 0,done:!0}}([i,s])}}};var fe=function(e){var n=this,t=Object(E.useState)(""),a=t[0],r=t[1],i=Object(E.useState)(!1),o=i[0],s=i[1],l=e.shoppingList.map((function(e){return e.assignee})),c=function(){return de(n,void 0,void 0,(function(){return pe(this,(function(n){switch(n.label){case 0:return""===a?[2]:(s(!0),[4,e.onCreateNewItem(a)]);case 1:return n.sent(),r(""),s(!1),[2]}}))}))};return y.a.createElement("div",{className:"editable-shopping-list-component"},y.a.createElement(me,{className:"editable-shopping-list-component-list",shoppingList:e.shoppingList,filter:e.filter,assigneeCandidates:l,onItemAssigneeChange:e.onItemAssigneeChange,onItemCheckedChange:e.onItemCheckedChange,onItemDeleted:e.onItemDeleted}),y.a.createElement("div",{className:"editable-shopping-list-component-controls"},y.a.createElement(j.a,{gutter:[16,8]},y.a.createElement(O.a,{xs:20,sm:20,md:20,lg:20,xl:20},y.a.createElement(S.a,{value:a,onChange:function(e){return r(e.target.value)},onPressEnter:c,disabled:o})),y.a.createElement(O.a,{xs:0,sm:0,md:4,lg:4,xl:4},y.a.createElement(C.a,{type:"primary",style:{width:"100%"},disabled:""===a,onClick:c,loading:o},"Hinzufügen")),y.a.createElement(O.a,{xs:4,sm:4,md:0,lg:0,xl:0},y.a.createElement(C.a,{className:"editable-shopping-list-small-add-button",type:"primary",disabled:""===a,onClick:c,loading:o},o?"":"+")))))},he=function(e,n,t,a){return new(t||(t=Promise))((function(r,i){function o(e){try{l(a.next(e))}catch(e){i(e)}}function s(e){try{l(a.throw(e))}catch(e){i(e)}}function l(e){var n;e.done?r(e.value):(n=e.value,n instanceof t?n:new t((function(e){e(n)}))).then(o,s)}l((a=a.apply(e,n||[])).next())}))},ge=function(e,n){var t,a,r,i,o={label:0,sent:function(){if(1&r[0])throw r[1];return r[1]},trys:[],ops:[]};return i={next:s(0),throw:s(1),return:s(2)},"function"==typeof Symbol&&(i[Symbol.iterator]=function(){return this}),i;function s(i){return function(s){return function(i){if(t)throw new TypeError("Generator is already executing.");for(;o;)try{if(t=1,a&&(r=2&i[0]?a.return:i[0]?a.throw||((r=a.return)&&r.call(a),0):a.next)&&!(r=r.call(a,i[1])).done)return r;switch(a=0,r&&(i=[2&i[0],r.value]),i[0]){case 0:case 1:r=i;break;case 4:return o.label++,{value:i[1],done:!1};case 5:o.label++,a=i[1],i=[0];continue;case 7:i=o.ops.pop(),o.trys.pop();continue;default:if(!(r=o.trys,(r=r.length>0&&r[r.length-1])||6!==i[0]&&2!==i[0])){o=0;continue}if(3===i[0]&&(!r||i[1]>r[0]&&i[1]<r[3])){o.label=i[1];break}if(6===i[0]&&o.label<r[1]){o.label=r[1],r=i;break}if(r&&o.label<r[2]){o.label=r[2],o.ops.push(i);break}r[2]&&o.ops.pop(),o.trys.pop();continue}i=n.call(e,o)}catch(e){i=[6,e],a=0}finally{t=r=0}if(5&i[0])throw i[1];return{value:i[0]?i[1]:void 0,done:!0}}([i,s])}}},be=function(){for(var e=0,n=0,t=arguments.length;n<t;n++)e+=arguments[n].length;var a=Array(e),r=0;for(n=0;n<t;n++)for(var i=arguments[n],o=0,s=i.length;o<s;o++,r++)a[r]=i[o];return a},Ee=J.a.TabPane;var ye=function(e){var n=this,t=function(n){e.onAuthenticationError&&n.graphQLErrors.find((function(e){var n;return 401===(null===(n=null==e?void 0:e.extensions)||void 0===n?void 0:n.code)}))?e.onAuthenticationError():H.a.error({message:n.networkError?"Uuups ein Fehler ist aufgetreten...":n.name,description:n.networkError?"Der Server antwortet nicht :(":n.message})},a=Object(x.b)(A,{onError:t}),r=a.loading,i=a.data,o=i?i.shoppingListItems.length:0,s=Object(E.useRef)(!1),l=Object(E.useRef)(null),c=Object(x.a)(P,{onError:t,update:function(e,n){var t=n.data.createShoppingListItem,a=e.readQuery({query:A}).shoppingListItems;a.find((function(e){return e._id===t._id}))||(e.writeQuery({query:A,data:{shoppingListItems:be(a,[t])}}),s.current=!0)}})[0];Object(E.useEffect)((function(){if(s.current&&null!==l.current){var e=l.current.getElementsByClassName("shopping-list-item");e.length>0&&e[e.length-1].scrollIntoView({behavior:"smooth"}),s.current=!1}}),[o]);var u=Object(x.a)(T,{onError:t})[0],m=Object(x.a)(D,{onError:t,update:function(e,n){var t=n.data.deleteShoppingListItem,a=e.readQuery({query:A}).shoppingListItems;e.writeQuery({query:A,data:{shoppingListItems:a.filter((function(e){return e._id!==t}))}})}})[0],d=Object(x.a)(q,{onError:t,update:function(e){e.writeQuery({query:A,data:{shoppingListItems:[]}})}})[0];Object(x.c)(B,{onSubscriptionData:function(e){if(e.subscriptionData.data){var n=e.subscriptionData.data.shoppingListChanged,t=e.client.readQuery({query:A}).shoppingListItems,a=t.findIndex((function(e){return e._id===n.item._id})),r=be(t);switch(n.type){case"ITEM_CHANGED":r[a]=n.item;break;case"ITEM_CREATED":a<0&&r.push(n.item);break;case"ITEM_DELETED":a>=0&&r.splice(a,1)}e.client.writeQuery({query:A,data:{shoppingListItems:r}})}}});var p,f=(null==i?void 0:i.shoppingListItems)||[],h=function(e,n,t){for(var a=new Map,r=0,i=e;r<i.length;r++){var o=i[r],s=n(o),l=t(o),c=a.get(s);c?c.push(l):a.set(s,[l])}return a}(f.filter((function(e){return!!e.assignee})),(function(e){return e.assignee}),(function(e){return e})),g=Array.from(h.entries()),b=function(e,n){u({variables:{id:e._id,state:n},optimisticResponse:{updateShoppingListItem:{__typename:"ShoppingListItem",_id:e._id,assignee:e.assignee,name:e.name,checked:n}}})},v=function(e,n){u({variables:{id:e._id,assignee:n}})},k=function(e){return he(n,void 0,void 0,(function(){return ge(this,(function(n){switch(n.label){case 0:return[4,m({variables:{id:e._id}})];case 1:return n.sent(),[2]}}))}))},w=Object(E.useState)("main"),I=w[0],S=w[1],L=Object(E.useState)(se.all),_=L[0],N=L[1],$=function(){return y.a.createElement(W.a.Group,{buttonStyle:"solid",size:"small",value:_,onChange:function(e){return N(e.target.value)}},y.a.createElement(W.a.Button,{value:se.all},y.a.createElement(U.a,null)),y.a.createElement(W.a.Button,{value:se.checked},y.a.createElement(V.a,null)),y.a.createElement(W.a.Button,{value:se.unchecked},y.a.createElement(Z.a,null)))},M=function(){return y.a.createElement(C.a,{size:"small",onClick:function(){return re(!0)}},y.a.createElement(X.a,null))},Q=Object(E.useState)(!1),ae=Q[0],re=Q[1];return y.a.createElement(E.Fragment,null,y.a.createElement("div",{className:"shopping-list-board"},y.a.createElement(K.a,{title:y.a.createElement("span",null,y.a.createElement("img",{className:"kaufhansel-image",src:"favicon.svg"}),y.a.createElement("span",null,"Kaufhansel")),subTitle:(p=h.get(I)||f,p.filter((function(e){return!e.checked})).length+"/"+p.length),className:"shopping-list-board-header",extra:y.a.createElement(j.a,{gutter:4},y.a.createElement(O.a,null,$()),y.a.createElement(O.a,null,M()))}),y.a.createElement(F.a,{spinning:r,tip:"Wird aktualisiert...",wrapperClassName:"shopping-list-board-spinner"},y.a.createElement(J.a,{defaultActiveKey:"main",activeKey:I,onChange:S,className:"shopping-list-board-tabs",animated:!1},y.a.createElement(Ee,{tab:"Alle",key:"main"},y.a.createElement("div",{ref:l,className:"shopping-list-board-main-tab-content"},y.a.createElement(fe,{shoppingList:f,filter:_,onItemAssigneeChange:v,onItemCheckedChange:b,onItemDeleted:k,onCreateNewItem:function(e){return he(n,void 0,void 0,(function(){return ge(this,(function(n){switch(n.label){case 0:return[4,c({variables:{name:e}})];case 1:return n.sent(),[2]}}))}))}}))),g.map((function(e){var n=e[0],t=e[1];return y.a.createElement(Ee,{tab:n,key:n},y.a.createElement(me,{className:"shopping-list-board-readonly-list",shoppingList:t,filter:_,onItemCheckedChange:b,onItemDeleted:k}))}))))),y.a.createElement(R.a,{visible:ae,closable:!1,onClose:function(){return re(!1)}},y.a.createElement(G.a,{mode:"inline",selectable:!1},y.a.createElement(G.a.Item,{onClick:function(){f.forEach((function(e){return b(e,!1)})),re(!1)}},y.a.createElement(Z.a,null),"Alles nochmal kaufen"),y.a.createElement(G.a.Item,{onClick:function(){f.forEach((function(e){return v(e,"")})),re(!1)}},y.a.createElement(Y.a,null),"Niemand kauft"),y.a.createElement(G.a.Item,{onClick:function(){z.a.confirm({title:"Wollen Sie die Einkaufsliste wirklich leeren?",onOk:function(){return d()},okText:"Ja",cancelText:"Nein",icon:y.a.createElement(ee.a,{style:{color:"#555555"}}),okType:"danger"}),re(!1)}},y.a.createElement(ne.a,null),"Alles löschen..."),y.a.createElement(G.a.Item,{onClick:function(){return re(!1)}},y.a.createElement(te.a,null),"Menü Schließen"))))},ve=("https:"===window.location.protocol?"wss":"ws")+"://"+window.location.host+"/graphql",ke=new f.a({uri:"/graphql"}),we=new g.a({uri:ve,options:{reconnect:!0}}),Ie=Object(p.d)((function(e){var n=e.query,t=Object(b.l)(n);return"OperationDefinition"===t.kind&&"subscription"===t.operation}),we,ke),Ce=new d.c({cache:new m.a,link:p.a.from([new h.a({delay:{initial:300,max:5e3,jitter:!0},attempts:{max:1/0,retryIf:function(e,n){return"shoppingListItems"!==n.operationName&&!!e}}}),Ie])});k.a.render(y.a.createElement(y.a.StrictMode,null,y.a.createElement(u.a,{client:Ce},y.a.createElement(I.a,null,y.a.createElement((function(){var e=Object(E.useState)(document.cookie.includes("SHOPPER_LOGGED_IN=true")),n=e[0],t=e[1],a=Object(w.g)();return y.a.createElement(w.d,null,y.a.createElement(w.b,{path:"/login"},y.a.createElement(Q,{onLoginSuccess:function(){t(!0),a.replace("/")}})),y.a.createElement(w.b,{path:"/",render:function(e){var a=e.location;return n?y.a.createElement(ye,{onAuthenticationError:function(){return t(!1)}}):y.a.createElement(w.a,{to:{pathname:"/login",state:{from:a}}})}}))}),null)))),document.getElementById("root"))}});
//# sourceMappingURL=main.js.map