macro package cj_log_framework.macros

import std.ast.* /* cjlint-ignore !G.PKG.01*/
public import cj_log_framework.LoggerFactroy
import std.collection.ArrayList

public macro Log(input: Tokens): Tokens {
    let decl = parseDecl(input)
    match (decl) {
        case classDecl: ClassDecl =>
            classDecl.body.decls.add(createLogger(), at: 0)
            classDecl.traverse(MyVisitor())
            return classDecl.toTokens()
        case funcDecl: FuncDecl =>
            funcDecl.block.nodes.add(createLogger(), at: 0)
            funcDecl.traverse(MyVisitor())
            return funcDecl.toTokens()
        case mainDecl: MainDecl =>
            mainDecl.block.nodes.add(createLogger(), at: 0)
            mainDecl.traverse(MyVisitor())
            return mainDecl.toTokens()
        case _ => diagReport(DiagReportLevel.ERROR, input, "Expected a class or function declaration", "")
    }
    return input
}

class MyVisitor <: Visitor {
    public func visit(callExpr: CallExpr) {
        let callFunc = callExpr.callFunc
        if (!(callFunc is MemberAccess)) {
            return
        }
        let memberAccess = match (callFunc as MemberAccess) {
            case Some(memberAccess) => memberAccess
            case None => return
        }
        let callName = match (memberAccess.baseExpr as RefExpr) {
            case Some(refExpr) => refExpr.identifier.value
            case None => return
        }
        if (callName != "log") {
            return
        }
        let arguments = callExpr.arguments
        let lineToken = Token(TokenKind.INTEGER_LITERAL, callExpr.callFunc.beginPos.line.toString())
        let tuple = TupleLiteral(quote(
            ("line", $(lineToken))
        ))
        let arg = Argument()
        arg.expr = tuple
        arguments.add(arg)
    }
}

func createLogger() {
    VarDecl(quote(
          let log = LoggerFactroy.createLogger(@sourcePackage() + "." + @sourceFile())
        ))
}
