using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlTableDefinition))]
    internal sealed class SqlScriptTableDefinition : SqlScriptCodeObject<SqlTableDefinition>
        {
        #region ctor{IServiceProvider,SqlTableDefinition}
        public SqlScriptTableDefinition(IServiceProvider context,SqlTableDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }