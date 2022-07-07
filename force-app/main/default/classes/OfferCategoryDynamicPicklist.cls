global class OfferCategoryDynamicPicklist extends VisualEditor.DynamicPickList {

    private List<Schema.PicklistEntry> entryList {get; set;}

    public OfferCategoryDynamicPicklist(){
        Schema.DescribeFieldResult fieldResult = Offer__c.Category__c.getDescribe();
        entryList = fieldResult.getPicklistValues();
    }

    /**
     * @description récupérer la valeur par défaut de la liste de sélection des paramètres
     * @author Elie Nassif | 12/12/2019
     * @return VisualEditor.DataRow
     **/
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue;
        for(Schema.PicklistEntry entry : Offer__c.Category__c.getDescribe().getPicklistValues()) {
            if(entry.isDefaultValue()) {
                defaultValue = new VisualEditor.DataRow(entry.getLabel(), entry.getValue());
                break;
            }
        }

        return defaultValue;
    }

    /**
     * @description récupérer toutes les valeurs possibles pour la liste de sélection des paramètres
     * @author Elie Nassif | 12/12/2019
     * @return VisualEditor.DynamicPickListRows
     **/
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows valueList = new VisualEditor.DynamicPickListRows();
        for(Schema.PicklistEntry entry : entryList) {
            valueList.addRow(new VisualEditor.DataRow(entry.getLabel(), entry.getValue()));
        }

        return valueList;
    }
}