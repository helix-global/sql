using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [AttributeUsage(AttributeTargets.Class,AllowMultiple=true,Inherited = false)]
    internal class SqlScriptObjectStatementPhraseAttribute : Attribute
        {
        public String StatementPhrase { get; }
        public SqlScriptObjectStatementPhraseAttribute(String StatementPhrase)
            {
            this.StatementPhrase = StatementPhrase;
            }
        }
    }