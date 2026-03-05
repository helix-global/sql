using System;
using SqlCodeDomObjectReference=Microsoft.SqlServer.Management.SqlParser.SqlCodeDom.SqlObjectReference;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCodeDomObjectReference))]
    internal sealed class SqlScriptObjectReference : SqlScriptCodeObject<SqlCodeDomObjectReference>
        {
        #region ctor{IServiceProvider,SqlCodeDomObjectReference}
        public SqlScriptObjectReference(IServiceProvider context,SqlCodeDomObjectReference source)
            : base(context,source)
            {
            }
        #endregion
        }
    }