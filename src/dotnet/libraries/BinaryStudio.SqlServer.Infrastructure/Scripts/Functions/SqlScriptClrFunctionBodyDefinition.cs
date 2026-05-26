using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlClrFunctionBodyDefinition))]
    internal sealed class SqlScriptClrFunctionBodyDefinition : SqlScriptFunctionBodyDefinition<SqlClrFunctionBodyDefinition>
        {
        #region ctor{IServiceProvider,SqlClrFunctionBodyDefinition}
        public SqlScriptClrFunctionBodyDefinition(IServiceProvider context,SqlClrFunctionBodyDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }