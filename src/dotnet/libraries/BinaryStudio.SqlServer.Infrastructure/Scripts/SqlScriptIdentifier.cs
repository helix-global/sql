using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using SqlCodeDomIdentifier=Microsoft.SqlServer.Management.SqlParser.SqlCodeDom.SqlIdentifier;
    [SqlScriptObject(typeof(SqlCodeDomIdentifier))]
    internal sealed class SqlScriptIdentifier : SqlScriptCodeObject<SqlCodeDomIdentifier>
        {
        #region ctor{IServiceProvider,SqlIdentifier}
        public SqlScriptIdentifier(IServiceProvider context,SqlCodeDomIdentifier source)
            : base(context,source)
            {
            }
        #endregion
        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Source.ToString();
            }
        #endregion
        }
    }