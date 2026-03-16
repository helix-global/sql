using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlInBooleanExpressionQueryValue))]
    internal sealed class SqlScriptInBooleanExpressionQueryValue : SqlScriptInBooleanExpressionValue<SqlInBooleanExpressionQueryValue>
        {
        #region ctor{IServiceProvider,SqlInBooleanExpressionQueryValue}
        public SqlScriptInBooleanExpressionQueryValue(IServiceProvider context,SqlInBooleanExpressionQueryValue source)
            : base(context,source)
            {
            }
        #endregion
        }
    }