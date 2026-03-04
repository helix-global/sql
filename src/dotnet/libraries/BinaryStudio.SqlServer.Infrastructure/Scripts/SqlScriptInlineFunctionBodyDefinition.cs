using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptInlineFunctionBodyDefinition : SqlScriptFunctionBodyDefinition<SqlInlineFunctionBodyDefinition>
        {
        #region ctor{IServiceProvider,SqlInlineFunctionBodyDefinition}
        public SqlScriptInlineFunctionBodyDefinition(IServiceProvider context,SqlInlineFunctionBodyDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }