using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlScalarRelationalFunctionDefinition))]
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