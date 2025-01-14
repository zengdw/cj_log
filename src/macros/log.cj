macro package cj_log_framework.macros

import std.ast.* /* cjlint-ignore !G.PKG.01*/
public import cj_log_framework.LoggerFactroy
import std.collection.ArrayList

public macro Log(input: Tokens): Tokens {
    let decl = parseDecl(input)
    match (decl) {
        case classDecl: ClassDecl =>
            classDecl.body.decls.prepend(createLogger())
            logAttr(classDecl.body.decls)
            return classDecl.toTokens()
        case funcDecl: FuncDecl =>
            funcDecl.block.nodes.prepend(createLogger())
            logAttr(funcDecl.block.nodes)
            return funcDecl.toTokens()
        case mainDecl: MainDecl =>
            mainDecl.block.nodes.prepend(createLogger())
            logAttr(mainDecl.block.nodes)
            return mainDecl.toTokens()
        case _ => diagReport(DiagReportLevel.ERROR, input, "Expected a class or function declaration", "")
    }
    return input
}

func logAttr(decls: ArrayList<Decl>) {
    for (decl in decls where decl is FuncDecl) {
        let funcDecl = (decl as FuncDecl).getOrThrow()
        logAttr(funcDecl.block.nodes)
    }
}

func logAttr(nodes: ArrayList<Node>) {
    for (node in nodes where node is CallExpr) {
        let callExpr = (node as CallExpr).getOrThrow()
        let callFunc = callExpr.callFunc
        if (!(callFunc is MemberAccess)) {
            continue
        }
        let memberAccess = (callFunc as MemberAccess).getOrThrow()
        if (!(memberAccess.baseExpr is RefExpr)) {
            continue
        }
        let callName = (memberAccess.baseExpr as RefExpr).getOrThrow().identifier.value
        if (callName != "log") {
            continue
        }
        let arguments = callExpr.arguments
        let lineToken = Token(TokenKind.INTEGER_LITERAL, callExpr.callFunc.beginPos.line.toString())
        let tuple = TupleLiteral(quote(
            ("line", $(lineToken))
        ))
        let arg = Argument()
        arg.expr = tuple
        arguments.append(arg)
    }
}

func createLogger() {
    VarDecl(quote(
          let log = LoggerFactroy.createLogger(@sourcePackage() + "." + @sourceFile())
        ))
}
