package cj_log.converter

public abstract class AbstractConverter <: Converter {
    private let optionList: ArrayList<String> = ArrayList()

    public func getFirstOption() {
        if (optionList.size > 0) {
            return optionList.get(0)
        }
        return Option<String>.None
    }

    public func addOption(optionList: ArrayList<String>) {
        for (op in optionList where op != "") {
            this.optionList.add(op)
        }
    }
    
    public func getOptionList() {
        return optionList
    }
}