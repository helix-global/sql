using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlScriptObjectStatementPhraseAttribute : Attribute
        {
        public String StatementPhrase { get; }
        public SqlScriptObjectStatementPhraseAttribute(String StatementPhrase)
            {
            this.StatementPhrase = StatementPhrase;
            }
        }
    }