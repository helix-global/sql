using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlMultistatementFunctionBodyDefinition))]
    internal sealed class SqlScriptMultistatementFunctionBodyDefinition : SqlScriptFunctionBodyDefinition<SqlMultistatementFunctionBodyDefinition>
        {
        #region ctor{IServiceProvider,SqlMultistatementFunctionBodyDefinition}
        public SqlScriptMultistatementFunctionBodyDefinition(IServiceProvider context,SqlMultistatementFunctionBodyDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }