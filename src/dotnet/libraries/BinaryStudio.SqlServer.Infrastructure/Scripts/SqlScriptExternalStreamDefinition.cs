using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlExternalStreamDefinition))]
    internal sealed class SqlScriptExternalStreamDefinition : SqlScriptCodeObject<SqlExternalStreamDefinition>
        {
        #region ctor{IServiceProvider,SqlExternalStreamDefinition}
        public SqlScriptExternalStreamDefinition(IServiceProvider context,SqlExternalStreamDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }