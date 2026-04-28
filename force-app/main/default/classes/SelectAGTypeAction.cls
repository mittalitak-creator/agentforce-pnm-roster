public class SelectAGTypeAction {
    
    @InvocableMethod(label='Select A&G Type' description='Presents Appeal vs Grievance selection with educational content' category='A&G Intake')
    public static List<Result> selectType(List<Request> requests) {
        List<Result> results = new List<Result>();
        
        for (Request req : requests) {
            Result result = new Result();
            result.selectedType = req.caseType;
            result.educationalContent = getEducationalContent();
            result.successMessage = 'Case type selected: ' + req.caseType;
            results.add(result);
        }
        
        return results;
    }
    
    private static String getEducationalContent() {
        return 'APPEAL: A request to review a decision about coverage, payment, or services. ' +
               'Examples: Denied claim, prior authorization denial, formulary exception.\n\n' +
               'GRIEVANCE: A complaint about service quality, access to care, or provider behavior. ' +
               'Examples: Wait times, staff behavior, billing issues, quality of care concerns.';
    }
    
    public class Request {
        @InvocableVariable(required=true label='Case Type' description='Select Appeal or Grievance')
        public String caseType;
    }
    
    public class Result {
        @InvocableVariable(label='Selected Type')
        public String selectedType;
        
        @InvocableVariable(label='Educational Content')
        public String educationalContent;
        
        @InvocableVariable(label='Success Message')
        public String successMessage;
    }
}
