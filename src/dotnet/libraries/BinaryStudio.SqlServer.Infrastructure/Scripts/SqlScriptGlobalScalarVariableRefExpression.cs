using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlGlobalScalarVariableRefExpression))]
    internal sealed class SqlScriptGlobalScalarVariableRefExpression : SqlScriptScalarExpression<SqlGlobalScalarVariableRefExpression>
        {
        public String VariableName {get{ return Source.VariableName; }}

        #region ctor{IServiceProvider,SqlGlobalScalarVariableRefExpression}
        public SqlScriptGlobalScalarVariableRefExpression(IServiceProvider context,SqlGlobalScalarVariableRefExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }