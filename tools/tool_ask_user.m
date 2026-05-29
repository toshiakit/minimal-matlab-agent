function result = tool_ask_user(question)
%TOOL_ASK_USER Ask the user for clarification.
    disp(newline + "Agent asks: " + string(question));
    result = string(input("Your answer>> ", "s"));
end
