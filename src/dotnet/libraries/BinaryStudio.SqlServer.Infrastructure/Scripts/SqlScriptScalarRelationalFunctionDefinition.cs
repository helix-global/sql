using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptScalarRelationalFunctionDefinition : SqlScriptFunctionDefinition<SqlScalarRelationalFunctionDefinition>
        {
        #region ctor{IServiceProvider,SqlScalarRelationalFunctionDefinition}
        public SqlScriptScalarRelationalFunctionDefinition(IServiceProvider context,SqlScalarRelationalFunctionDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }