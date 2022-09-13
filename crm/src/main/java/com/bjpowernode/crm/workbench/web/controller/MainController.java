package com.bjpowernode.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class MainController {

    @RequestMapping("/workbench/main/index.do")
    public String index(){
        //整个页面刷，不需要ajax
        //跳转到main/index.jsp，有视图解析器
        return "workbench/main/index";
    }
}
