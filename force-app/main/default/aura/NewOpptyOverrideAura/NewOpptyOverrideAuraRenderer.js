({
    rerender : function(component, helper) {
        this.superRerender();
        helper.helperInIt(component, event); 
    }
})