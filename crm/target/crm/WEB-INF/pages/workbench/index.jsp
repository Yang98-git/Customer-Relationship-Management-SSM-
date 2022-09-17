<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String basePath=request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath()+"/";
%>
<html>
<head>
<base href="<%=basePath%>">
<meta charset="UTF-8">
<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript">

	//页面加载完毕
	$(function(){

		//导航中所有文本颜色为黑色
		$(".liClass > a").css("color" , "black");

		//默认选中导航菜单中的第一个菜单项
		$(".liClass:first").addClass("active");

		//第一个菜单项的文字变成白色
		$(".liClass:first > a").css("color" , "white");

		//给所有的菜单项注册鼠标单击事件
		$(".liClass").click(function(){
			//移除所有菜单项的激活状态
			$(".liClass").removeClass("active");
			//导航中所有文本颜色为黑色
			$(".liClass > a").css("color" , "black");
			//当前项目被选中
			$(this).addClass("active");
			//当前项目颜色变成白色
			$(this).children("a").css("color","white");
		});

		window.open("workbench/main/index.do","workareaFrame");

        //给logoutBtn添加单击事件
        $("#logoutBtn").click(function (){
            //发送同步请求找controller：地址栏，超链接，form
            window.location.href="settings/qx/user/logout.do";
        });

	});

</script>

</head>
<body>

<!-- 我的资料 -->
<div class="modal fade" id="myInformation" role="dialog">
    <div class="modal-dialog" role="document" style="width: 30%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">My Profile</h4>
            </div>
            <div class="modal-body">
                <div style="position: relative; left: 40px;">
                    Name：<b>张三</b><br><br>
                    Account：<b>zhangsan</b><br><br>
                    Organization：<b>1005，市场部，二级部门</b><br><br>
                    E-mail：<b>zhangsan@bjpowernode.com</b><br><br>
                    Expiry Date：<b>2017-02-14 10:10:10</b><br><br>
                    Allowing IP Address：<b>127.0.0.1,192.168.100.2</b>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改密码的模态窗口 -->
<div class="modal fade" id="editPwdModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 70%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">Change Password</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">
                    <div class="form-group">
                        <label for="oldPwd" class="col-sm-2 control-label">Original Password</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="oldPwd" style="width: 200%;">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="newPwd" class="col-sm-2 control-label">New Password</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="newPwd" style="width: 200%;">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="confirmPwd" class="col-sm-2 control-label">Confirm Password</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="confirmPwd" style="width: 200%;">
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="window.location.href='login.html';">Update</button>
            </div>
        </div>
    </div>
</div>

<!-- 退出系统的模态窗口 -->
<div class="modal fade" id="exitModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 30%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">Quit</h4>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to log out?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" data-dismiss="modal" id="logoutBtn">Confirm</button>
            </div>
        </div>
    </div>
</div>

<!-- 顶部 -->
<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
    <div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2022&nbsp;Yang Xu</span></div>
    <div style="position: absolute; top: 15px; right: 35px;">
        <ul>
            <li class="dropdown-menu-left user-dropdown">
                <a href="javascript:void(0)" style="text-decoration: none; color: white;" class="dropdown-toggle" data-toggle="dropdown">
                    <span class="glyphicon glyphicon-user"></span> ${sessionScope.sessionUser.name} <span class="caret"></span>
                </a>
                <ul class="dropdown-menu">
                    <li><a href="settings/index.html"><span class="glyphicon glyphicon-wrench"></span> Settings</a></li>
                    <li><a href="javascript:void(0)" data-toggle="modal" data-target="#myInformation"><span class="glyphicon glyphicon-file"></span> My Profile</a></li>
                    <li><a href="javascript:void(0)" data-toggle="modal" data-target="#editPwdModal"><span class="glyphicon glyphicon-edit"></span> Change Password</a></li>
                    <li><a href="javascript:void(0);" data-toggle="modal" data-target="#exitModal"><span class="glyphicon glyphicon-off"></span> Logout </a></li>
                </ul>
            </li>
        </ul>
    </div>
</div>

<!-- 中间 -->
<div id="center" style="position: absolute;top: 50px; bottom: 30px; left: 0px; right: 0px;">

    <!-- 导航 -->
    <div id="navigation" style="left: 0px; width: 18%; position: relative; height: 100%; overflow:auto;">

        <ul id="no1" class="nav nav-pills nav-stacked">
            <li class="liClass"><a href="workbench/main/index.do" target="workareaFrame"><span class="glyphicon glyphicon-home"></span> Workbench</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-tag"></span> Posts</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-time"></span> Examinations</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-user"></span> Customers pool</a></li>
            <li class="liClass"><a href="workbench/activity/index.do" target="workareaFrame"><span class="glyphicon glyphicon-play-circle"></span> Market Activities</a></li>
            <li class="liClass"><a href="clue/index.html" target="workareaFrame"><span class="glyphicon glyphicon-search"></span> Clues(potential customers)</a></li>
            <li class="liClass"><a href="customer/index.html" target="workareaFrame"><span class="glyphicon glyphicon-user"></span> Clients</a></li>
            <li class="liClass"><a href="contacts/index.html" target="workareaFrame"><span class="glyphicon glyphicon-earphone"></span> Contacts </a></li>
            <li class="liClass"><a href="transaction/index.html" target="workareaFrame"><span class="glyphicon glyphicon-usd"></span> Transactions(opportunities)</a></li>
            <li class="liClass"><a href="visit/index.html" target="workareaFrame"><span class="glyphicon glyphicon-phone-alt"></span> After-Sales Follow Up</a></li>
            <li class="liClass">
                <a href="#no2" class="collapsed" data-toggle="collapse"><span class="glyphicon glyphicon-stats"></span> Statistical charts</a>
                <ul id="no2" class="nav nav-pills nav-stacked collapse">
                    <li class="liClass"><a href="chart/activity/index.html" target="workareaFrame">&nbsp;&nbsp;&nbsp;<span class="glyphicon glyphicon-chevron-right"></span> Market Activity Chart</a></li>
                    <li class="liClass"><a href="chart/clue/index.html" target="workareaFrame">&nbsp;&nbsp;&nbsp;<span class="glyphicon glyphicon-chevron-right"></span> Clue Chart</a></li>
                    <li class="liClass"><a href="chart/customerAndContacts/index.html" target="workareaFrame">&nbsp;&nbsp;&nbsp;<span class="glyphicon glyphicon-chevron-right"></span> Customer and Contact Chart</a></li>
                    <li class="liClass"><a href="chart/transaction/index.html" target="workareaFrame">&nbsp;&nbsp;&nbsp;<span class="glyphicon glyphicon-chevron-right"></span> Transaction Chart</a></li>
                </ul>
            </li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-file"></span> Statements</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-shopping-cart"></span> Sales Orders</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-send"></span> Invoices</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-earphone"></span> Follow-up</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-leaf"></span> Products </a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><span class="glyphicon glyphicon-usd"></span> Quotes</a></li>
        </ul>

        <!-- 分割线 -->
        <div id="divider1" style="position: absolute; top : 0px; right: 0px; width: 1px; height: 100% ; background-color: #B3B3B3;"></div>
    </div>

    <!-- 工作区 -->
    <div id="workarea" style="position: absolute; top : 0px; left: 18%; width: 82%; height: 100%;">
        <iframe style="border-width: 0px; width: 100%; height: 100%;" name="workareaFrame"></iframe>
    </div>

</div>

<div id="divider2" style="height: 1px; width: 100%; position: absolute;bottom: 30px; background-color: #B3B3B3;"></div>

<!-- 底部 -->
<div id="down" style="height: 30px; width: 100%; position: absolute;bottom: 0px;"></div>

</body>
</html>
