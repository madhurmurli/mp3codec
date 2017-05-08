function bark= getbark(f,bark_list)
    %bark=13*atan(0.00076*f)+3.5*atan((f/7500)^2);
    bark=find(f<bark_list,1);
end