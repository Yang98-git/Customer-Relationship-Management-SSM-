<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath=request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath()+"/";
%>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<%--Pagination plugin--%>
<link rel="stylesheet" type="text/css" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

<script type="text/javascript">

	$(function(){
		//给createActivityBtn添加单击事件
		$("#createActivityBtn").click(function (){
			//初始化工作，重置表单，需要DOM对象，jQuery转DOM
			$("#createActivityForm")[0].reset();
			//弹出创建市场活动的模态窗口
			$("#createActivityModal").modal("show");
		});

		//给保存按钮添加单击事件
		$("#saveCreateActivity").click(function () {
			//收集参数
			var owner = $("#create-marketActivityOwner").val(); //此value是u.id
			var name = $.trim($("#create-marketActivityName").val());
			var startDate = $("#create-startDate").val();
			var endDate = $("#create-endDate").val();
			var cost = $.trim($("#create-cost").val());
			var description = $.trim($("#create-description").val());
			//判断数据是否合法，表单验证
			if (owner==""){
				alert("The owner cannot be empty!")
				return;
			}
			if (name==""){
				alert("The name cannot be empty!")
				return;
			}
			if (startDate!="" && endDate!=""){
				if (endDate<startDate){ //js弱类型语言可以直接<> 比较
					alert("The end date cannot be before the start date!")
					return;
				}
			}
			//正则表达式：匹配非负整数
			// ^(([1-9]\d*)|0)$
			var regExp =/^(([1-9]\d*)|0)$/;
			if (!regExp.test(cost)){
				alert("The cost can only be a non-negative integer!")
				return;
			}
			//发送异步请求
			$.ajax({
				url:'workbench/activity/saveCreateActivity.do',
				data:{
					owner:owner,
					name:name,
					startDate:startDate,
					endDate:endDate,
					cost:cost,
					description:description
				},
				type:'post',
				dataType:'json',
				success:function (data){
					if (data.code=='1'){
						//关闭模态窗口
						$("#createActivityModal").modal("hide");
						//刷新市场活动列，显示第一页数据，保持每页显示条数不变
					}else {
						//失败提示
						alert(data.message);
						//模态窗口不关闭
						$("#createActivityModal").modal("show"); //可以不写
					}
					//保存市场活动成功，自动刷新第一页
					pageSize = $("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'); //获取上次选择的pageSize
					queryActivityByConditionForPage(1,pageSize);
				}
			});

		});

		//当容器加载完成，对容器调用工具函数(datetimepicker插件)
		//id选择器只能选一个
		//$("input[name='mydate']")
		$(".mydate").datetimepicker({ //通过参数，显示效果
			language:'en',
			format:'yyyy-mm-dd',
			minView:'month', //最小视图
			initialDate: new Date(), //初始化显示的日期
			autoclose:true, //选择完日期之后，是否自动关闭。默认false
			todayBtn:true, //是否显示今天按钮。默认false
			clearBtn:true //是否清空。默认false

		});

		//当市场活动主页面加载完成，查询所有数据的第一页以及所有数据的总条数，默认每页显示10条
		queryActivityByConditionForPage(1,10);

		//给查询按钮添加单击事件
		$("#queryActivityBtn").click(function () {
			//查询所有符合条件数据的第一页以及所有符合条件数据的总条数
			pageSize = $("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'); //获取上次选择的pageSize
			queryActivityByConditionForPage(1, pageSize);
		});

		//全选按钮添加单击事件
		$("#checkAll").click(function () {
			//如果全选按钮选中，列表所有checkbox都选中
			//this代表当前的DOM对象
			//$("#checkAll").prop("checked");
			/*if(this.checked){
				//父子选择器 空格：获取所有子标签 >: 获取一级子标签
				$("#tBody input[type='checkbox']").prop("checked", true);
			}else {
				$("#tBody input[type='checkbox']").prop("checked", false);
			}*/
			//所有子标签checked属性和父标签一致
			$("#tBody input[type='checkbox']").prop("checked", this.checked);
		});
		//给列表checkbox添加单击事件，列表checkbox是ajax动态拼出来的需要使用on()，来绑定事件
		/*$("#tBody input[type='checkbox']").click(function () {
			//列表中所有checkbox选中，全选按钮也选中
			//获取数组长度
			if ($("#tBody input[type='checkbox']").size() == $("#tBody input[type='checkbox']:checked").size()){
				$("#checkAll").prop("checked", true);
			}else {
				//列表中有一个没选中，全选就false
				$("#checkAll").prop("checked", false);
			}
		});*/
		$("#tBody").on("click", "input[type='checkbox']", function (){
			//列表中所有checkbox选中，全选按钮也选中
			//获取数组长度
			if ($("#tBody input[type='checkbox']").size() == $("#tBody input[type='checkbox']:checked").size()){
				$("#checkAll").prop("checked", true);
			}else {
				//列表中有一个没选中，全选就false
				$("#checkAll").prop("checked", false);
			}
		});

		//给删除按钮添加单击事件
		$("#deleteActivityBtn").click(function () {
			//收集参数
			//获取列表中所有被选中的checkbox的id value
			var checkedIds = $("#tBody input[type='checkbox']:checked"); //DOM数组
			//至少要有一个被选中
			if(checkedIds.size()==0){
				alert("Please select the marking activity you want to delete!");
				return;
			}

			if (window.confirm("Are sure you want to delete?")) { //确认删除
				var ids="";
				$.each(checkedIds, function () {
					//this就是obj, DOM对象取value，jQuery取val()
					ids+="id="+this.value+"&";
				});
				ids.substring(0, ids.length-1); //截取最后一个&

				//发送异步请求
				$.ajax({
					url:'workbench/activity/deleteActivityByIds.do',
					data: ids,
					type:'post',
					dataType:'json',
					success:function (data) {
						if (data.code=='1'){
							//刷新市场活动列表，显示第一页数据，保持每页显示条数不变
							pageSize = $("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'); //获取上次选择的pageSize
							queryActivityByConditionForPage(1, pageSize);
						}else {
							//失败提示
							alert(data.message);
						}
					}
				});
			}
		});

		//给修改按钮添加单击事件
		$("#editActivityBtn").click(function (){
			//收集参数
			//获取列表中被选中的checkBox
			var checkedId = $("#tBody input[type='checkbox']:checked");
			if(checkedId.size()==0){
				alert("Please select the marking activity you want to modify!");
				return;
			}
			if(checkedId.size()>1){ //只能选一个
				alert("Only one activity can be selected to modify!");
				return;
			}
			var id = checkedId.val(); //jquery对象
			//发送请求
			$.ajax({
				url: 'workbench/activity/queryActivityById.do',
				data: {
					id:id
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					//把返回的信息显示到修改模态窗口
					$("#edit-id").val(data.id); //给id隐藏域赋值
					$("#edit-marketActivityOwner").val(data.owner); //选择下拉列表的owner，用户u.id
					$("#edit-marketActivityName").val(data.name);
					$("#edit-startTime").val(data.startDate);
					$("#edit-endTime").val(data.endDate);
					$("#edit-cost").val(data.cost);
					$("#edit-description").val(data.description);
					//弹出修改市场活动的模态窗口
					$("#editActivityModal").modal("show");
				}
			});
		});

		//给更新按钮添加单击事件
		$("#saveEditActivityBtn").click(function () {
			//收集参数
			var id = $("#edit-id").val();
			var owner = $("#edit-marketActivityOwner").val(); //这个就是u.id
			var name = $.trim($("#edit-marketActivityName").val());
			var startDate = $("#edit-startTime").val();
			var endDate = $("#edit-endTime").val();
			var cost = $.trim($("#edit-cost").val());
			var description = $.trim($("#edit-description").val());
			//表单验证
			if (owner==""){
				alert("The owner cannot be empty!")
				return;
			}
			if (name==""){
				alert("The name cannot be empty!")
				return;
			}
			if (startDate!="" && endDate!=""){
				if (endDate<startDate){ //js弱类型语言可以直接<> 比较
					alert("The end date cannot be before the start date!")
					return;
				}
			}
			//正则表达式：匹配非负整数
			// ^(([1-9]\d*)|0)$
			var regExp =/^(([1-9]\d*)|0)$/;
			if (!regExp.test(cost)){
				alert("The cost can only be a non-negative integer!")
				return;
			}
			//发送请求
			$.ajax({
				url:'workbench/activity/saveEditActivity.do',
				data:{
					id:id,
					owner:owner,
					name:name,
					startDate:startDate,
					endDate:endDate,
					cost:cost,
					description:description
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code=='1'){
						//关闭模态窗口
						$("#editActivityModal").modal("hide");
						//刷新市场活动列，显示原来页数据，保持每页显示条数不变
					}else {
						//失败提示
						alert(data.message);
						//模态窗口不关闭
						$("#editActivityModal").modal("show"); //可以不写
					}
					//更新市场活动成功，自动刷新，保持页号和每页显示条数不变
					pageSize = $("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'); //获取上次选择的pageSize
					pageNo = $("#demo_pag1").bs_pagination('getOption', 'currentPage')
					queryActivityByConditionForPage(pageNo,pageSize);
				}
			});
		});
	});

	//封装函数一定要在入口函数外面封装
	function queryActivityByConditionForPage(pageNo, pageSize) {
		//当市场活动主页面加载完成，查询所有数据的第一页以及所有数据的总条数，默认每页显示10条
		//收集参数
		//查询数据一般不需要去空格，不需要表单验证，不会修改数据库的数据
		var name = $("#query-name").val();
		var owner = $("#query-owner").val();
		var startDate = $("#query-startDate").val();
		var endDate = $("#query-endDate").val();
		//var pageNo = 1;
		//var pageSize = 10;
		$.ajax({
			url: 'workbench/activity/queryActivityByConditionForPage.do',
			data: {
				name: name,
				owner: owner,
				startDate: startDate,
				endDate: endDate,
				pageNo: pageNo,
				pageSize: pageSize
			},
			type: 'post',
			dataType: 'json',
			success: function (data) {
				//显示总条数
				//$("#totalRowsB").text(data.totalRows);
				//显示市场活动列表
				//作用域的数据使用jstl标签遍历
				//js变量使用jQuery遍历
				//遍历activityList
				var htmlStr = "";
				$.each(data.activityList, function (index, obj) {
					htmlStr+="<tr class='active'>";
					/*每条市场活动id赋值给checkbox*/
					htmlStr+="<td><input type='checkbox' value='"+obj.id+"'/></td>";
					htmlStr+="<td><a style='text-decoration: none; cursor: pointer;' onclick='window.location.href='detail.html';'>"+obj.name+"</a></td>";
					htmlStr+="<td>"+obj.owner+"</td>";
					htmlStr+="<td>"+obj.startDate+"</td>";
					htmlStr+="<td>"+obj.endDate+"</td>";
					htmlStr+="</tr>";
				});
				$("#tBody").html(htmlStr);

				//每次翻页重新查询之后，取消全选
				$("#checkAll").prop("checked", false);

				//计算总页数
				var totalPages=1;
				if (data.totalRows % pageSize == 0){ //整除 5/3 取2
					totalPages=data.totalRows/pageSize;
				}else {
					// parseInt() 获取小数的整数
					totalPages=parseInt(data.totalRows/pageSize)+1;
				}

				//对容器调用分页插件bs_pagination,显示翻页信息
				//需要返回的data信息，所以写在success中
				$("#demo_pag1").bs_pagination({
					currentPage: pageNo, //当前页号，pageNo，用户输入

					rowsPerPage: pageSize, //pageSize，用户输入
					totalRows: data.totalRows, //总条数，默认1000，数据库查出来
					totalPages: totalPages, //总页数，必填

					visiblePageLinks: 5, //一组显示几页，默认5

					showGoToPage: true, //是否显示跳转到具体页面，默认T
					showRowsPerPage: true, //是否显示“每页显示条数”
					showRowsInfo: true, //是否显示记录信息

					//pageObj: 翻页对象，有以上{}中所有参数
					onChangePage: function (event, pageObj){ //切换页号，执行js
						//return pageNo and pageSize after a link has clicked
						//alert(pageObj.currentPage);
						//alert(pageObj.rowsPerPage);
						//切换页号，根据页号和size再次查询
						queryActivityByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
					}
				});
			}
		});
	}

</script>
</head>
<body>

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">Create a marketing activity</h4>
				</div>
				<div class="modal-body">

					<form id="createActivityForm" class="form-horizontal" role="form">

						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">Owner<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">
								  <c:forEach items="${userList}" var="u">
									<option value="${u.id}">${u.name}</option>
								  </c:forEach>
								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">Name <span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>

						<div class="form-group">
							<label for="create-startDate" class="col-sm-2 control-label">Start Date</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="create-startDate" readonly>
							</div>
							<label for="create-endDate" class="col-sm-2 control-label">Date Closed</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="create-endDate" readonly>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">Cost </label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">Description </label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>

					</form>

				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">Close </button>
					<button type="button" class="btn btn-primary" id="saveCreateActivity">Save</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<input type="hidden" id="edit-id"><%--隐藏域存储活动id--%>
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">Modify marketing activity</h4>
				</div>
				<div class="modal-body">

					<form class="form-horizontal" role="form">

						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">Owner<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">
									<c:forEach items="${userList}" var="u">
										<option value="${u.id}">${u.name}</option>
									</c:forEach>
								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">Name <span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName" value="发传单">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">Start Date</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="edit-startTime" readonly>
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">Date Closed</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="edit-endTime" readonly>
							</div>
						</div>

						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">Cost </label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost" value="5,000">
							</div>
						</div>

						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">Description </label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description">description</textarea>
							</div>
						</div>

					</form>

				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">Close </button>
					<button type="button" class="btn btn-primary" id="saveEditActivityBtn">Update </button>
				</div>
			</div>
		</div>
	</div>

	<!-- 导入市场活动的模态窗口 -->
    <div class="modal fade" id="importActivityModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">Import Marketing Activities</h4>
                </div>
                <div class="modal-body" style="height: 350px;">
                    <div style="position: relative;top: 20px; left: 50px;">
                        请选择要上传的文件：<small style="color: gray;">[仅支持.xls]</small>
                    </div>
                    <div style="position: relative;top: 40px; left: 50px;">
                        <input type="file" id="activityFile">
                    </div>
                    <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;" >
                        <h3>IMPORTANT</h3>
                        <ul>
                            <li>操作仅针对Excel，仅支持后缀名为XLS的文件。</li>
                            <li>给定文件的第一行将视为字段名。</li>
                            <li>请确认您的文件大小不超过5MB。</li>
                            <li>日期值以文本形式保存，必须符合yyyy-MM-dd格式。</li>
                            <li>日期时间以文本形式保存，必须符合yyyy-MM-dd HH:mm:ss的格式。</li>
                            <li>默认情况下，字符编码是UTF-8 (统一码)，请确保您导入的文件使用的是正确的字符编码方式。</li>
                            <li>建议您在导入真实数据之前用测试文件测试文件导入功能。</li>
                        </ul>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close </button>
                    <button id="importActivityBtn" type="button" class="btn btn-primary">Import</button>
                </div>
            </div>
        </div>
    </div>


	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>Market Activities List</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">

			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">Name </div>
				      <input class="form-control" type="text" id="query-name">
				    </div>
				  </div>

				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">Owner</div>
				      <input class="form-control" type="text" id="query-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">Start Date</div>
					  <input class="form-control mydate" type="text" id="query-startDate" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">Date Closed</div>
					  <input class="form-control mydate" type="text" id="query-endDate">
				    </div>
				  </div>
					<%--submit会发送同步请求，改成button--%>
				  <button type="button" class="btn btn-default" id="queryActivityBtn">Query</button>

				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createActivityBtn"><span class="glyphicon glyphicon-plus"></span> Create </button>
				  <button type="button" class="btn btn-default" id="editActivityBtn"><span class="glyphicon glyphicon-pencil"></span> Modify </button>
				  <button type="button" class="btn btn-danger" id="deleteActivityBtn"><span class="glyphicon glyphicon-minus"></span> Delete </button>
				</div>
				<div class="btn-group" style="position: relative; top: 18%;">
                    <button type="button" class="btn btn-default" data-toggle="modal" data-target="#importActivityModal" ><span class="glyphicon glyphicon-import"></span> Upload list Data (Import)</button>
                    <button id="exportActivityAllBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> Download list Data (Export Batch)</button>
                    <button id="exportActivityXzBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> Download list Data (Export Selected)</button>
                </div>
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAll"/></td>
							<td>Name </td>
                            <td>Owner</td>
							<td>Start Date</td>
							<td>Date Closed</td>
						</tr>
					</thead>
					<tbody id="tBody">
						<%--<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">发传单</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                        </tr>--%>
					</tbody>
				</table>

				<div id="demo_pag1"></div>
			</div>

			<%--<div style="height: 50px; position: relative;top: 30px;">
				<div>
					<button type="button" class="btn btn-default" style="cursor: default;"><b id="totalRowsB">50</b> records</button>
				</div>
				<div class="btn-group" style="position: relative;top: -34px; left: 105px;">
					<button type="button" class="btn btn-default" style="cursor: default;">Display </button>
					<div class="btn-group">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
							10
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu" role="menu">
							<li><a href="#">20</a></li>
							<li><a href="#">30</a></li>
						</ul>
					</div>
					<button type="button" class="btn btn-default" style="cursor: default;"> items</button>
				</div>

				<div style="position: relative;top: -88px; left: 300px;">
					<nav>
						<ul class="pagination">
							<li class="disabled"><a href="#">Home Page</a></li>
							<li class="disabled"><a href="#">Back</a></li>
							<li class="active"><a href="#">1</a></li>
							<li><a href="#">2</a></li>
							<li><a href="#">3</a></li>
							<li><a href="#">4</a></li>
							<li><a href="#">5</a></li>
							<li><a href="#">Next </a></li>
							<li class="disabled"><a href="#">Last Page</a></li>
						</ul>
					</nav>
				</div>
			</div>--%>

		</div>

	</div>
</body>
</html>
