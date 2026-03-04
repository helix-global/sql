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
        }
    }