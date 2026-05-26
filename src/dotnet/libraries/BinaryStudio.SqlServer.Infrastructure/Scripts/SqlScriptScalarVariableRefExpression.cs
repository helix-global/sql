using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class SqlScriptScalarVariableRefExpression<T> : SqlScriptScalarExpression<T>,ISqlScriptScalarVariableRefExpression
        where T : SqlScalarVariableRefExpression
        {
        [UsedImplicitly][Field] public String VariableName { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptScalarVariableRefExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return VariableName;
            }
        #endregion
        }

    [SqlScriptObject(typeof(SqlScalarVariableRefExpression))]
    internal sealed class SqlScriptScalarVariableRefExpression : SqlScriptScalarVariableRefExpression<SqlScalarVariableRefExpression>
        {
        #region ctor{IServiceProvider,SqlScalarVariableRefExpression}
        public SqlScriptScalarVariableRefExpression(IServiceProvider context,SqlScalarVariableRefExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }