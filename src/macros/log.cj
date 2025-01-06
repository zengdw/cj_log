macro package cj_log_framework.macros

import std.ast.{Tokens, parseDecl, ClassDecl, FuncDecl, diagReport, DiagReportLevel, VarDecl, Token, TokenKind, MainDecl, Decl, Node}
public import cj_log_framework.logger.LoggerFactroy
import std.collection.ArrayList

public macro log(input: Tokens): Tokens {
    let decl = parseDecl(input)
    input.dump()
    match (decl) {
        case classDecl: ClassDecl =>
            classDecl.body.decls.prepend(createLogger(classDecl.identifier))
            return classDecl.toTokens()
        case funcDecl: FuncDecl =>
            funcDecl.block.nodes.prepend(createLogger(funcDecl.identifier))
            return funcDecl.toTokens()
        case mainDecl: MainDecl =>
            mainDecl.block.nodes.prepend(createLogger(mainDecl.identifier))
            logAttr(mainDecl.block.nodes)
            return mainDecl.toTokens()
        case _ => diagReport(DiagReportLevel.ERROR, input, "Expected a class or function declaration", "")
    }
    return input
}

func logAttr(decls: ArrayList<Node>): ArrayList<Node> {
    for (decl in decls where decl is VarDecl) {
        let varDecl = (decl as VarDecl).getOrThrow()
        varDecl.dump()
    }

    return decls
}

func createLogger(loggerName: Token) {
    let loggerNameToken = Token(TokenKind.STRING_LITERAL, loggerName.value)
    VarDecl(quote(
          let log = LoggerFactroy.createLogger($(loggerNameToken))
        ))
}   
