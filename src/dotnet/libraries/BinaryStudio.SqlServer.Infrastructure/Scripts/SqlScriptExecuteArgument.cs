using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [SqlScriptObject(typeof(SqlExecuteArgument))]
    internal sealed class SqlScriptExecuteArgument : SqlScriptCodeObject<SqlExecuteArgument>
        {
        [UsedImplicitly][Field] public Boolean IsOutput { get; }
        [UsedImplicitly][Field] public ISqlScriptScalarVariableRefExpression Parameter { get; }
        [UsedImplicitly][Field] public ISqlScriptScalarExpression Value { get; }

        #region ctor{IServiceProvider,SqlExecuteArgument}
        public SqlScriptExecuteArgument(IServiceProvider context,SqlExecuteArgument source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Script;
            }
        #endregion
        }
    }