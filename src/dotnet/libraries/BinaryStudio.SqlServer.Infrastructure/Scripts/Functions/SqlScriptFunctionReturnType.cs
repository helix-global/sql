using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptFunctionReturnType<T> : SqlScriptCodeObject<T>
        where T : SqlFunctionReturnType
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptFunctionReturnType(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }