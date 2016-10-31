//: Playground - noun: a place where people can play

import Cocoa

enum Token {
    
    case Number(Int)
    case Plus
    
} // Token

class LexicalAnalyzer {
    
    enum TokenError: Error {
        
        case InvalidCharacter(Character)
        
    } // TokenError
    
    private let input: String.CharacterView
    private var position: String.CharacterView.Index
    
    init(input: String) {
        
        self.input = input.characters
        self.position = self.input.startIndex
        
    } // init
    
    private func peek() -> Character? {
        
        guard position < input.endIndex else {
            
            return nil
            
        } // guard
        
        return input[position]
        
    } // peek
    
    private func advance() {
        
        input.formIndex(&position, offsetBy: 1, limitedBy: input.endIndex)
        
    } // advance
    
    func getNumber() -> Int {
        
        var value = 0
        
        while let nextCharacter = peek() {
            
            switch nextCharacter {
                
            case "0" ... "9":
                
                let digitValue = Int(String(nextCharacter))!
                
                value = 10 * value + digitValue
                
                advance()
                
            default:
                
                return value
                
            } // switch
            
        } // while
        
        return value
        
    } // getNumber
    
    func lex() throws -> [Token] {
        
        var tokens = [Token]()
        
        while let nextCharacter = peek() {
            
            switch nextCharacter {
                
            case "0" ... "9":
                
                let value = getNumber()
                
                tokens.append(.Number(value))
                
            case "+":
                
                tokens.append(.Plus)
                
                advance()
                
            case " ":
                
                advance()
                
            default:
                
                throw TokenError.InvalidCharacter(nextCharacter)
                
            } // switch
            
        } // while
        
        return tokens
        
    } // lex
    
} // LexicalAnalyzer

class Parser {
    
    enum ErrorToken: Error {
        
        case UnexpectedEndOfInput
        case InvalidToken(Token)
        
    } // ErrorToken
    
    let tokens: [Token]
    var position = 0
    
    init(tokens: [Token]) {
        
        self.tokens = tokens
        
    } // init
    
    func getNextToken() -> Token? {
        
        guard position < tokens.count else {
            
            return nil
            
        } // guard
        
        defer {
            
            position += 1
            
        } // defer
        
        return tokens[position]
        
    } // getNextToken
    
    func getNumber() throws -> Int {
        
        guard let token = getNextToken() else {
            
            throw ErrorToken.UnexpectedEndOfInput
            
        } // guard
        
        switch token {
            
        case .Number(let value):
            
            return value
            
        case .Plus:
            
            throw ErrorToken.InvalidToken(token)
            
        } // switch
        
    } // getNumber
    
    func parse() throws -> Int {
        
        var value = try getNumber()
        
        while let token = getNextToken() {
            
            switch token {
                
            case .Plus:
                
                let nextNumber = try getNumber()
                
                value += nextNumber
                
            case .Number:
                
                throw ErrorToken.InvalidToken(token)
                
            } // switch
            
        } // while
        
        return value
        
    } // parse
    
} // Parser

func evaluate(input: String) {
    
    print("\nEvaluando: \(input)")
    
    let lexer = LexicalAnalyzer(input: input)
    
    do {
        
        let tokens = try lexer.lex()
        
        print("\nTokens: \(tokens)")
        
        let parser = Parser(tokens: tokens)
        
        let result = try parser.parse()
        
        print("\nResultado: \(result)")
        
    } catch LexicalAnalyzer.TokenError.InvalidCharacter(let character) {
        
        print("\nLa cadena de entrada contenía un caracter inválido: \(character)")
        
    } catch Parser.ErrorToken.UnexpectedEndOfInput {
        
        print("\nFin de cadena no esperado")
        
    } catch Parser.ErrorToken.InvalidToken(let token) {
        
        print("\nToken inválido: \(token)")
        
    } catch {
        
        print("\nHa ocurrido un error: \(error)")
        
    } // catch
    
} // evaluate

evaluate(input: "10 + 5 + 5")
