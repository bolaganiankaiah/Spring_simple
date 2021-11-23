package com.Controller;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
@Controller
public class NameController {
@RequestMapping("/")
	public String display()
	{
		return "index";
	}	
}
