using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlFunctionDefinitionError))]
    internal sealed class SqlScriptFunctionDefinitionError : SqlScriptFunctionDefinition<SqlFunctionDefinitionError>
        {
        #region ctor{IServiceProvider,SqlFunctionDefinitionError}
        public SqlScriptFunctionDefinitionError(IServiceProvider context,SqlFunctionDefinitionError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }