using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlTableClrFunctionDefinition))]
    internal sealed class SqlScriptTableClrFunctionDefinition : SqlScriptFunctionDefinition<SqlTableClrFunctionDefinition>
        {
        #region ctor{IServiceProvider,SqlTableClrFunctionDefinition}
        public SqlScriptTableClrFunctionDefinition(IServiceProvider context,SqlTableClrFunctionDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }