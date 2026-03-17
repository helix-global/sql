using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptFilterExpression<T> : SqlScriptCodeObject<T>,ISqlScriptFilterExpression
        where T : SqlFilterExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptFilterExpression(IServiceProvider context,T source)
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