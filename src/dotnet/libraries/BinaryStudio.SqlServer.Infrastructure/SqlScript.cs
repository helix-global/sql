using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SqlScript
        {
        public String Script { get; }
        public Boolean? QuotedIdentifiers { get; }
        public Boolean? AnsiNulls { get; }

        #region ctor{String,Boolean?,Boolean?}
        public SqlScript(String Script,Boolean? QuotedIdentifiers,Boolean? AnsiNulls)
            {
            this.Script = Script;
            this.QuotedIdentifiers = QuotedIdentifiers;
            this.AnsiNulls = AnsiNulls;
            }
        #endregion
        #region M:ToString:String
        override public String ToString()
            {
            return Script;
            }
        #endregion
        }
    }
