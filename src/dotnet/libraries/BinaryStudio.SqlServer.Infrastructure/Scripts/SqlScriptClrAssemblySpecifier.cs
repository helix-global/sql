using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptClrAssemblySpecifier<T> : SqlScriptCodeObject<T>
        where T : SqlClrAssemblySpecifier
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptClrAssemblySpecifier(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }